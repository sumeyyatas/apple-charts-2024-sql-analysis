# 🎵 Apple Charts 2024 — SQL Analysis

A MySQL data modeling and analysis project built on the top 20 songs from Apple Music's
**Top Songs of 2024: Global** chart. Songs, artists, collaborations, genres, and explicit
content information are modeled in a relational database; several questions are answered
using JOINs, GROUP BY, CTEs (`WITH`), and window functions (`RANK`, `SUM() OVER`).

## 📊 Data Model

| Table | Description |
|---|---|
| `Artists` | Artist name, gender, country |
| `Songs` | Song title, main artist, duration, Apple Charts position |
| `Collabs` | Additional (featured) artists per song |
| `Genres` | Genre per song |
| `ExclusiveContent` | Songs containing explicit content |
| `SongFullReport` (view) | A report view combining all information in a single query |

```
Artists ─┬─< Songs ─┬─< Collabs >─┐
         │           ├─< Genres   │
         │           └─< ExclusiveContent
         └───────────────────────┘ (Collabs.ArtistID also links back to Artists)
```

## 🔍 Key Findings

- **85%** of the top 20 songs' main artists are from the USA; the remaining 15% is split
  evenly between Canada, Ireland, and Japan.
- **71%** of artists are male and 29% are female (based on 21 unique artists). Looking at
  it song-by-song (since some artists have 2 songs), the ratio is 65% Male / 35% Female.
- The most popular genre is **Pop** (7 songs), followed by Hip-Hop and Country.
- **Half** of the top 20 songs contain explicit content.
- Collaborative songs (`Like That`, `A Bar Song`, etc.) make up **20%** of the list
  (4 unique songs; `Like That` appears as 2 rows because it has 2 separate collaborators,
  so this is calculated by unique song count, not row count).

## 🧩 SQL Techniques Used

- Multi-table `JOIN` / `LEFT JOIN`
- `GROUP BY` + `HAVING`
- Aggregate functions (`COUNT`, `AVG`, `SEC_TO_TIME`, `TIME_TO_SEC`)
- **CTE** (`WITH ... AS`) — readable, step-by-step queries
- **Window functions** — `RANK() OVER (PARTITION BY ...)`, `SUM() OVER (ORDER BY ...)`
  for cumulative ratios
- `CREATE VIEW` — a reusable reporting layer

## 📁 Files

- [`topsongs_2024_v2.sql`](./topsongs_2024_v2.sql) — database schema + all queries
- [`generate_charts.py`](./generate_charts.py) — chart generation from query results (Python/matplotlib)
- `charts_dashboard.png` — a single dashboard combining all analyses

## 📈 Visuals

![Dashboard](./charts_dashboard.png)

## ⚙️ How to Run

```bash
# 1. Set up the database in MySQL
mysql -u root -p < topsongs_2024_v2.sql

# 2. Generate the charts (optional, requires Python)
pip install pandas matplotlib
python3 generate_charts.py
```

## 🔗 Related Post

You can read the write-up behind this project and the thought process on [Medium here](#).

## 📝 Data Source

Apple Music, *Top Songs of 2024: Global* year-end chart (December 2024).

---
*This project is for educational/portfolio purposes; all song and artist names belong to their respective rights holders.*
