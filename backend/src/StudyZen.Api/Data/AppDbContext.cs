using Microsoft.EntityFrameworkCore;
using StudyZen.Api.Models;

namespace StudyZen.Api.Data;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<Disciplina> Disciplinas => Set<Disciplina>();
    public DbSet<Avaliacao> Avaliacoes => Set<Avaliacao>();
    public DbSet<Subtarefa> Subtarefas => Set<Subtarefa>();
    public DbSet<RegistroHumor> RegistrosHumor => Set<RegistroHumor>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Disciplina>(e =>
        {
            e.ToTable("disciplinas");
            e.HasKey(d => d.Id);
            e.Property(d => d.Nome).IsRequired().HasMaxLength(120);
            e.Property(d => d.CargaHoraria).IsRequired();
            e.Property(d => d.CriadoEm).IsRequired();
        });

        modelBuilder.Entity<Avaliacao>(e =>
        {
            e.ToTable("avaliacoes");
            e.HasKey(a => a.Id);
            e.Property(a => a.Titulo).IsRequired().HasMaxLength(120);
            e.Property(a => a.Tipo).IsRequired().HasMaxLength(50);
            e.Property(a => a.DataEntrega).IsRequired();
            e.Property(a => a.CriadoEm).IsRequired();
            e.HasOne(a => a.Disciplina)
                .WithMany()
                .HasForeignKey(a => a.DisciplinaId)
                .OnDelete(DeleteBehavior.Cascade);
            e.HasMany(a => a.Subtarefas)
                .WithOne(s => s.Avaliacao)
                .HasForeignKey(s => s.AvaliacaoId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<Subtarefa>(e =>
        {
            e.ToTable("subtarefas");
            e.HasKey(s => s.Id);
            e.Property(s => s.Titulo).IsRequired().HasMaxLength(200);
            e.Property(s => s.Concluida).IsRequired();
        });

        modelBuilder.Entity<RegistroHumor>(e =>
        {
            e.ToTable("registros_humor");
            e.HasKey(h => h.Id);
            e.Property(h => h.Nivel).IsRequired();
            e.Property(h => h.Emoji).IsRequired().HasMaxLength(10);
            e.Property(h => h.Sentimento).HasMaxLength(50);
            e.Property(h => h.DataRegistro).IsRequired();
        });
    }
}
