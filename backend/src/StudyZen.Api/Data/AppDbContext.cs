using Microsoft.EntityFrameworkCore;
using StudyZen.Api.Models;

namespace StudyZen.Api.Data;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<Disciplina> Disciplinas => Set<Disciplina>();

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
    }
}
