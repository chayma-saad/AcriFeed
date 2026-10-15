from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
import joblib
from datetime import datetime
import logging

# Initialize Flask app
app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load your ML models (you'll train these separately)
try:
    condition_model = joblib.load('models/locust_condition_model.pkl')
    humidity_model = joblib.load('models/humidity_model.pkl')
    feeding_model = joblib.load('models/feeding_model.pkl')
    anomaly_model = joblib.load('models/anomaly_model.pkl')
    logger.info("✅ All ML models loaded successfully")
except Exception as e:
    logger.warning(f"❌ Models not loaded: {e}")
    condition_model = None
    humidity_model = None
    feeding_model = None
    anomaly_model = None

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'models_loaded': {
            'condition': condition_model is not None,
            'humidity': humidity_model is not None,
            'feeding': feeding_model is not None,
            'anomaly': anomaly_model is not None
        }
    })

@app.route('/predict/condition', methods=['POST'])
def predict_condition():
    """Predict locust condition based on sensor data"""
    try:
        data = request.get_json()
        logger.info(f"Condition prediction request: {data}")

        # Extract features (adjust based on your model)
        features = [
            data.get('temperature', 0),
            data.get('humidity', 0),
            data.get('food_level', 0),
            data.get('water_level', 0),
            data.get('colony_activity', 0)
        ]

        if condition_model:
            # Use your actual trained model
            prediction = condition_model.predict([features])[0]
            probabilities = condition_model.predict_proba([features])[0]
            confidence = max(probabilities)

            # Map prediction to condition
            conditions = {0: 'normal', 1: 'hungry', 2: 'stressed'}
            condition = conditions.get(prediction, 'normal')
        else:
            # Fallback rule-based prediction
            condition, confidence = rule_based_condition(features)

        # Generate factors and recommendations
        factors = analyze_condition_factors(features, condition)
        recommendation = generate_condition_recommendation(condition, features)

        return jsonify({
            'condition': condition,
            'confidence': round(confidence, 2),
            'factors': factors,
            'recommendation': recommendation,
            'timestamp': datetime.now().isoformat()
        })

    except Exception as e:
        logger.error(f"Condition prediction error: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/predict/humidity', methods=['POST'])
def predict_humidity():
    """Predict future humidity levels"""
    try:
        data = request.get_json()
        current_data = data.get('current_data', {})
        history = data.get('history', [])

        if humidity_model and history:
            # Use ML model for prediction
            features = prepare_humidity_features(current_data, history)
            prediction = humidity_model.predict([features])[0]
            confidence = 0.85
        else:
            # Rule-based prediction
            prediction, confidence = rule_based_humidity_prediction(current_data)

        trend = 'stable'
        if len(history) >= 2:
            current = current_data.get('humidity', 0)
            previous = history[-1].get('humidity', 0)
            trend = 'increasing' if current > previous else 'decreasing' if current < previous else 'stable'

        adjustment_needed = abs(prediction - 55) > 10  # Ideal humidity ~55%

        return jsonify({
            'predicted_humidity': round(prediction, 2),
            'confidence': round(confidence, 2),
            'trend': trend,
            'adjustment_needed': adjustment_needed,
            'timestamp': datetime.now().isoformat()
        })

    except Exception as e:
        logger.error(f"Humidity prediction error: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/predict/feeding', methods=['POST'])
def predict_feeding():
    """Get feeding recommendations"""
    try:
        data = request.get_json()
        sensor_data = data.get('sensor_data', {})
        condition = data.get('current_condition', 'normal')
        time_of_day = data.get('time_of_day', 12)

        if feeding_model:
            # Use ML model
            features = prepare_feeding_features(sensor_data, condition, time_of_day)
            amount = feeding_model.predict([features])[0]
            confidence = 0.8
        else:
            # Rule-based recommendation
            amount, confidence = rule_based_feeding(sensor_data, condition, time_of_day)

        urgency = calculate_feeding_urgency(sensor_data, condition)
        schedule = 'immediate' if urgency > 0.7 else 'next_hour' if urgency > 0.4 else 'scheduled'

        recommendations = generate_feeding_recommendations(condition, sensor_data)

        return jsonify({
            'amount': round(amount, 2),
            'urgency': round(urgency, 2),
            'schedule': schedule,
            'recommendations': recommendations,
            'timestamp': datetime.now().isoformat()
        })

    except Exception as e:
        logger.error(f"Feeding prediction error: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/predict/anomaly', methods=['POST'])
def predict_anomaly():
    """Detect anomalies in sensor data"""
    try:
        data = request.get_json()
        sensor_data = data.get('sensor_data', {})
        condition = data.get('current_condition', 'normal')

        if anomaly_model:
            # Use ML model
            features = prepare_anomaly_features(sensor_data)
            is_anomaly = anomaly_model.predict([features])[0] == -1
            anomaly_score = anomaly_model.decision_function([features])[0]
        else:
            # Rule-based anomaly detection
            is_anomaly, anomaly_score = rule_based_anomaly_detection(sensor_data, condition)

        severity, issues, action = analyze_anomaly(sensor_data, condition, anomaly_score)

        return jsonify({
            'is_anomaly': is_anomaly,
            'anomaly_score': round(anomaly_score, 2),
            'severity': severity,
            'detected_issues': issues,
            'recommended_action': action,
            'timestamp': datetime.now().isoformat()
        })

    except Exception as e:
        logger.error(f"Anomaly detection error: {e}")
        return jsonify({'error': str(e)}), 500

# Rule-based fallback functions
def rule_based_condition(features):
    temp, humidity, food, water, activity = features

    if activity < 30 and food > 70:
        return 'stressed', 0.8
    elif activity > 70 and food < 30:
        return 'hungry', 0.75
    elif temp > 32 or temp < 22:
        return 'stressed', 0.7
    elif humidity < 40 or humidity > 75:
        return 'stressed', 0.6
    else:
        return 'normal', 0.9

def rule_based_humidity_prediction(current_data):
    current_humidity = current_data.get('humidity', 55)
    temperature = current_data.get('temperature', 28)

    # Simple physics-based prediction
    temp_effect = (temperature - 25) * -0.8
    prediction = current_humidity + temp_effect
    prediction = max(20, min(90, prediction))

    return prediction, 0.7

def rule_based_feeding(sensor_data, condition, time_of_day):
    base_amount = 50
    food_level = sensor_data.get('food_level', 50)
    activity = sensor_data.get('colony_activity', 50)

    # Adjust based on conditions
    if condition == 'hungry':
        base_amount *= 1.5
    elif condition == 'stressed':
        base_amount *= 0.7

    if food_level < 30:
        base_amount *= 1.3

    if activity > 80:
        base_amount *= 1.2

    # Time of day adjustment
    if 6 <= time_of_day <= 18:  # Daytime
        base_amount *= 1.1

    return max(10, min(150, base_amount)), 0.8

def rule_based_anomaly_detection(sensor_data, condition):
    score = 0.0
    temp = sensor_data.get('temperature', 28)
    humidity = sensor_data.get('humidity', 55)
    food = sensor_data.get('food_level', 50)
    water = sensor_data.get('water_level', 50)
    activity = sensor_data.get('colony_activity', 50)

    # Temperature anomalies
    if temp < 22 or temp > 34:
        score += 0.4

    # Humidity anomalies
    if humidity < 40 or humidity > 70:
        score += 0.3

    # Resource anomalies
    if food < 20:
        score += 0.2
    if water < 20:
        score += 0.2

    # Behavioral anomalies
    if condition == 'stressed' and temp > 30:
        score += 0.3

    is_anomaly = score > 0.5
    return is_anomaly, min(1.0, score)

# Helper functions (implement based on your logic)
def analyze_condition_factors(features, condition):
    # Analyze which factors contribute to the condition
    factors = []
    temp, humidity, food, water, activity = features

    if condition == 'stressed':
        if temp > 32: factors.append("High temperature")
        if temp < 22: factors.append("Low temperature")
        if humidity < 40: factors.append("Low humidity")
        if humidity > 75: factors.append("High humidity")
        if activity < 30: factors.append("Low activity")

    elif condition == 'hungry':
        if food < 30: factors.append("Low food levels")
        if activity > 70: factors.append("High activity")

    return factors if factors else ["Normal operating conditions"]

def generate_condition_recommendation(condition, features):
    recommendations = {
        'normal': "Continue current maintenance schedule.",
        'hungry': "Consider increasing food supply and monitor activity.",
        'stressed': "Check environmental conditions and reduce stressors."
    }
    return recommendations.get(condition, "Monitor colony closely.")

def calculate_feeding_urgency(sensor_data, condition):
    urgency = 0.0
    food_level = sensor_data.get('food_level', 50)

    if food_level < 15: urgency += 0.8
    elif food_level < 30: urgency += 0.5
    elif food_level < 50: urgency += 0.2

    if condition == 'hungry': urgency += 0.6
    elif condition == 'stressed': urgency += 0.3

    return min(1.0, urgency)

def generate_feeding_recommendations(condition, sensor_data):
    recommendations = []
    food_level = sensor_data.get('food_level', 50)

    if food_level < 20:
        recommendations.append("Food levels critical - refill immediately")
    elif food_level < 40:
        recommendations.append("Consider refilling food soon")

    if condition == 'hungry':
        recommendations.append("Increase feeding frequency")
    elif condition == 'stressed':
        recommendations.append("Provide high-nutrition supplements")

    return recommendations if recommendations else ["Continue regular feeding schedule"]

def analyze_anomaly(sensor_data, condition, anomaly_score):
    issues = []
    temp = sensor_data.get('temperature', 28)
    humidity = sensor_data.get('humidity', 55)
    food = sensor_data.get('food_level', 50)
    water = sensor_data.get('water_level', 50)

    if temp < 22 or temp > 34:
        issues.append(f"Temperature out of range: {temp}°C")
    if humidity < 40 or humidity > 70:
        issues.append(f"Humidity out of range: {humidity}%")
    if food < 20:
        issues.append("Food levels critically low")
    if water < 20:
        issues.append("Water levels critically low")

    if anomaly_score < 0.3:
        severity = "low"
        action = "Monitor situation"
    elif anomaly_score < 0.6:
        severity = "medium"
        action = "Check sensors and conditions"
    elif anomaly_score < 0.8:
        severity = "high"
        action = "Immediate attention required"
    else:
        severity = "critical"
        action = "Emergency intervention needed"

    return severity, issues, action

# Feature preparation functions (to be implemented based on your models)
def prepare_humidity_features(current_data, history):
    # Implement based on your humidity model requirements
    return [current_data.get('humidity', 55), current_data.get('temperature', 28)]

def prepare_feeding_features(sensor_data, condition, time_of_day):
    # Implement based on your feeding model requirements
    condition_enc = 0 if condition == 'normal' else 1 if condition == 'hungry' else 2
    return [
        sensor_data.get('food_level', 50),
        sensor_data.get('colony_activity', 50),
        condition_enc,
        time_of_day
    ]

def prepare_anomaly_features(sensor_data):
    # Implement based on your anomaly model requirements
    return [
        sensor_data.get('temperature', 28),
        sensor_data.get('humidity', 55),
        sensor_data.get('food_level', 50),
        sensor_data.get('water_level', 50),
        sensor_data.get('colony_activity', 50)
    ]

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)