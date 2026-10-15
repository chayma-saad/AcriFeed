using Microsoft.EntityFrameworkCore;
using LocustMonitoring.API.Models;

namespace LocustMonitoring.API.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users { get; set; }
    public DbSet<EnvironmentalData> EnvironmentalData { get; set; }
    public DbSet<Prediction> Predictions { get; set; }
    public DbSet<ActionTaken> ActionsTaken { get; set; }
    public DbSet<Notification> Notifications { get; set; }
    public DbSet<SensorData> SensorData { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configure User entity with snake_case column names
        modelBuilder.Entity<User>(entity =>
        {
            entity.ToTable("users");
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Username).HasColumnName("username");
            entity.Property(e => e.Email).HasColumnName("email");
            entity.Property(e => e.PasswordHash).HasColumnName("password_hash");
            entity.Property(e => e.FullName).HasColumnName("full_name");
            entity.Property(e => e.Role).HasColumnName("role");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.Property(e => e.UpdatedAt).HasColumnName("updated_at");
            entity.HasIndex(e => e.Username).IsUnique();
            entity.HasIndex(e => e.Email).IsUnique();
        });

        // Configure EnvironmentalData entity
        modelBuilder.Entity<EnvironmentalData>(entity =>
        {
            entity.ToTable("environmental_data");
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Temperature).HasColumnName("temperature");
            entity.Property(e => e.Humidity).HasColumnName("humidity");
            entity.Property(e => e.LightLevel).HasColumnName("light_level");
            entity.Property(e => e.ActivityIndex).HasColumnName("activity_index");
            entity.Property(e => e.FeedLevel).HasColumnName("feed_level");
            entity.Property(e => e.RecordedAt).HasColumnName("recorded_at");
        });

        // Configure Prediction entity
        modelBuilder.Entity<Prediction>(entity =>
        {
            entity.ToTable("predictions");
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.ConditionType).HasColumnName("condition_type");
            entity.Property(e => e.Confidence).HasColumnName("confidence");
            entity.Property(e => e.FrameData).HasColumnName("frame_data");
            entity.Property(e => e.RecommendedAction).HasColumnName("recommended_action");
            entity.Property(e => e.Notes).HasColumnName("notes");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.EnvironmentalDataId).HasColumnName("environmental_data_id");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            
            // Relationships
            entity.HasOne(p => p.User)
                  .WithMany()
                  .HasForeignKey(p => p.UserId)
                  .OnDelete(DeleteBehavior.SetNull);

            entity.HasOne(p => p.EnvironmentalData)
                  .WithMany()
                  .HasForeignKey(p => p.EnvironmentalDataId)
                  .OnDelete(DeleteBehavior.SetNull);
        });

        // Configure ActionTaken entity
        modelBuilder.Entity<ActionTaken>(entity =>
        {
            entity.ToTable("actions_taken");
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.PredictionId).HasColumnName("prediction_id");
            entity.Property(e => e.ActionType).HasColumnName("action_type");
            entity.Property(e => e.ActionDetails).HasColumnName("action_details");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            
            // Relationships
            entity.HasOne(a => a.Prediction)
                  .WithMany()
                  .HasForeignKey(a => a.PredictionId)
                  .OnDelete(DeleteBehavior.SetNull);

            entity.HasOne(a => a.User)
                  .WithMany()
                  .HasForeignKey(a => a.UserId)
                  .OnDelete(DeleteBehavior.SetNull);
        });

        // Configure Notification entity
        modelBuilder.Entity<Notification>(entity =>
        {
            entity.ToTable("notifications");
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.Title).HasColumnName("title");
            entity.Property(e => e.Message).HasColumnName("message");
            entity.Property(e => e.NotificationType).HasColumnName("notification_type");
            entity.Property(e => e.IsRead).HasColumnName("is_read");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");

            // Relationships
            entity.HasOne(n => n.User)
                  .WithMany()
                  .HasForeignKey(n => n.UserId)
                  .OnDelete(DeleteBehavior.SetNull);
        });

        // Configure SensorData entity
        modelBuilder.Entity<SensorData>(entity =>
        {
            entity.ToTable("sensor_data");
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Temperature).HasColumnName("temperature");
            entity.Property(e => e.Humidity).HasColumnName("humidity");
            entity.Property(e => e.FoodLevel).HasColumnName("food_level");
            entity.Property(e => e.WaterLevel).HasColumnName("water_level");
            entity.Property(e => e.ColonyActivity).HasColumnName("colony_activity");
            entity.Property(e => e.PredictedHumidity).HasColumnName("predicted_humidity");
            entity.Property(e => e.FeedingRecommendation).HasColumnName("feeding_recommendation");
            entity.Property(e => e.AnomalyScore).HasColumnName("anomaly_score");
            entity.Property(e => e.ConditionStatus).HasColumnName("condition_status");
            entity.Property(e => e.Timestamp).HasColumnName("timestamp");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
        });
    }
}

