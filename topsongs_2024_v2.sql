-- =====================================================================
-- APPLE CHARTS 2024 - TOP 20 SONGS ANALYSIS (v2)
-- =====================================================================
-- This file is the enhanced version of the original project.
-- Additions: CTEs (WITH), window functions (RANK, ROW_NUMBER),
-- view creation, and additional analytical queries.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS top_songs_of_2024;
USE top_songs_of_2024;

-- ---------------------------------------------------------------------
-- TABLE STRUCTURE
-- ---------------------------------------------------------------------

CREATE TABLE Artists (
    ArtistID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Gender VARCHAR(10),
    Country VARCHAR(100)
);

INSERT INTO Artists (ArtistID, Name, Gender, Country)
VALUES
(1, 'Kendrick Lamar', 'Male', 'USA'),
(2, 'Taylor Swift', 'Female', 'USA'),
(3, 'Billie Eilish', 'Female', 'USA'),
(4, 'Benson Boone', 'Male', 'USA'),
(5, 'Sabrina Carpenter', 'Female', 'USA'),
(6, 'Shaboozey', 'Male', 'USA'),
(7, 'Post Malone', 'Male', 'USA'),
(8, 'Teddy Swims', 'Male', 'USA'),
(9, 'Metro Boomin', 'Male', 'USA'),
(10, 'Future', 'Male', 'USA'),
(11, 'Creepy Nuts', 'Male', 'Japan'),
(12, 'SZA', 'Female', 'USA'),
(13, 'Morgan Wallen', 'Male', 'USA'),
(14, 'Noah Kahan', 'Male', 'USA'),
(15, 'Jack Harlow', 'Male', 'USA'),
(16, 'Zach Bryan', 'Male', 'USA'),
(17, 'Hozier', 'Male', 'Ireland'),
(18, 'Tate McRae', 'Female', 'Canada'),
(19, 'Tommy Richman', 'Male', 'USA'),
(20, 'Lil Baby', 'Male', 'USA'),
(21, 'Kacey Musgraves', 'Female', 'USA');


CREATE TABLE Songs (
    SongID INT PRIMARY KEY AUTO_INCREMENT,
    Title VARCHAR(150) NOT NULL,
    ArtistID INT NOT NULL,
    Duration TIME NOT NULL,
    AppleChartsPosition INT NOT NULL,
    FOREIGN KEY (ArtistID) REFERENCES Artists(ArtistID)
);

-- FIX: the title of the song at position 10 was corrected to "Bling-Bang-Bang-Born"
-- (source: Apple Music Top Songs of 2024: Global official chart)
INSERT INTO Songs (Title, ArtistID, AppleChartsPosition, Duration)
VALUES
('Not Like Us', 1, 1, '00:04:34'),
('Beautiful Things', 4, 2, '00:03:00'),
('Espresso', 5, 3, '00:02:55'),
('A Bar Song', 6, 4, '00:02:51'),
('Cruel Summer', 2, 5, '00:02:58'),
('I Had Some Help', 7, 6, '00:02:58'),
('Lose Control', 8, 7, '00:03:30'),
('Like That', 10, 8, '00:04:27'),
('Birds Of A Feather', 3, 9, '00:03:30'),
('Bling-Bang-Bang-Born', 11, 10, '00:02:48'),
('Snooze', 12, 11, '00:03:21'),
('Last Night', 13, 12, '00:02:43'),
('Stick Season', 14, 13, '00:03:02'),
('Lovin On Me', 15, 14, '00:02:18'),
('I Remember Everything', 16, 15, '00:03:47'),
('Please Please Please', 5, 16, '00:03:06'),
('Too Sweet', 17, 17, '00:04:11'),
('Greedy', 18, 18, '00:02:11'),
('Millon Dollar Baby', 19, 19, '00:02:35'),
('Fortnight', 2, 20, '00:03:48');


CREATE TABLE Collabs (
    SongID INT,
    ArtistID INT,
    PRIMARY KEY (SongID, ArtistID),
    FOREIGN KEY (SongID) REFERENCES Songs(SongID),
    FOREIGN KEY (ArtistID) REFERENCES Artists(ArtistID)
);

INSERT INTO Collabs (SongID, ArtistID)
VALUES (8, 9), (8, 1), (6, 13), (20, 7), (15, 21);

CREATE TABLE Genres (
    GenreID INT PRIMARY KEY AUTO_INCREMENT,
    SongID INT NOT NULL,
    Genre VARCHAR(50) NOT NULL,
    FOREIGN KEY (SongID) REFERENCES Songs(SongID)
);

INSERT INTO Genres (SongID, Genre)
VALUES
(1, 'Hip-Hop'), (2, 'Pop'), (3, 'Pop'), (4, 'Country'), (5, 'Pop'),
(6, 'Country'), (7, 'Rock'), (8, 'Hip-Hop'), (9, 'Pop'), (10, 'Hip-Hop'),
(11, 'R&B'), (12, 'Country'), (13, 'Alternative'), (14, 'Hip-Hop'),
(15, 'Country'), (16, 'Pop'), (17, 'Alternative'), (18, 'Pop'),
(19, 'R&B'), (20, 'Pop');

CREATE TABLE ExclusiveContent (
    SongID INT PRIMARY KEY
);

INSERT INTO ExclusiveContent (SongID)
VALUES (1), (3), (4), (6), (8), (11), (12), (14), (16), (18);


-- =====================================================================
-- BASIC QUERIES (carried over from v1)
-- =====================================================================

-- Number of songs per genre
SELECT Genre, COUNT(SongID) AS NumberOfSongs
FROM Genres
GROUP BY Genre
HAVING COUNT(SongID) >= 1
ORDER BY NumberOfSongs DESC;

-- Song - artist - collaborator table
SELECT
    Songs.AppleChartsPosition,
    Songs.Title AS Song,
    Songs.Duration AS Time,
    Artists.Name AS Artist,
    Collaborators.Name AS Collaborator
FROM Songs
JOIN Artists ON Songs.ArtistID = Artists.ArtistID
LEFT JOIN Collabs ON Songs.SongID = Collabs.SongID
LEFT JOIN Artists AS Collaborators ON Collabs.ArtistID = Collaborators.ArtistID
ORDER BY Songs.AppleChartsPosition;

-- Number of songs by gender
SELECT
    Artists.Gender AS Artists_Gender,
    COUNT(Songs.SongID) AS Song_Count
FROM Songs
JOIN Artists ON Songs.ArtistID = Artists.ArtistID
GROUP BY Artists.Gender
ORDER BY Song_Count DESC;

-- Artist - country
SELECT Name AS Artist, Country FROM Artists;

-- Explicit content status
SELECT
    Songs.Title AS Song,
    Artists.Name AS Artist,
    IF(ExclusiveContent.SongID IS NOT NULL, 'Yes', 'No') AS ExclusiveContent
FROM Songs
JOIN Artists ON Songs.ArtistID = Artists.ArtistID
LEFT JOIN ExclusiveContent ON Songs.SongID = ExclusiveContent.SongID
ORDER BY Songs.AppleChartsPosition;


-- =====================================================================
-- NEW QUERIES (v2) — CTE, WINDOW FUNCTIONS, VIEW
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) The top-ranked (most popular) song of each genre — WINDOW FUNCTION
-- ---------------------------------------------------------------------
-- RANK() is used to rank songs within each Genre by AppleChartsPosition,
-- and only the "representative" (top-ranked) song of that genre is listed.
WITH RankedByGenre AS (
    SELECT
        g.Genre,
        s.Title,
        s.AppleChartsPosition,
        RANK() OVER (PARTITION BY g.Genre ORDER BY s.AppleChartsPosition ASC) AS GenreRank
    FROM Genres g
    JOIN Songs s ON g.SongID = s.SongID
)
SELECT Genre, Title, AppleChartsPosition
FROM RankedByGenre
WHERE GenreRank = 1
ORDER BY AppleChartsPosition;


-- ---------------------------------------------------------------------
-- 2) Average duration of collaborative vs. solo songs — CTE
-- ---------------------------------------------------------------------
-- First we determine in a CTE whether each song is a collaboration,
-- then we compare the average duration of the two groups.
WITH SongCollabFlag AS (
    SELECT
        s.SongID,
        s.Duration,
        CASE WHEN c.SongID IS NOT NULL THEN 'Collab' ELSE 'Solo' END AS SongType
    FROM Songs s
    LEFT JOIN (SELECT DISTINCT SongID FROM Collabs) c ON s.SongID = c.SongID
)
SELECT
    SongType,
    COUNT(*) AS SongCount,
    SEC_TO_TIME(AVG(TIME_TO_SEC(Duration))) AS AverageDuration
FROM SongCollabFlag
GROUP BY SongType;


-- ---------------------------------------------------------------------
-- 3) Cumulative "explicit content" ratio — WINDOW FUNCTION
-- ---------------------------------------------------------------------
-- Shows how the running percentage of explicit content changes as you
-- move down the chart.
SELECT
    s.AppleChartsPosition,
    s.Title,
    IF(ec.SongID IS NOT NULL, 1, 0) AS IsExclusive,
    ROUND(
        SUM(IF(ec.SongID IS NOT NULL, 1, 0)) OVER (ORDER BY s.AppleChartsPosition)
        / s.AppleChartsPosition * 100, 1
    ) AS RunningExclusivePct
FROM Songs s
LEFT JOIN ExclusiveContent ec ON s.SongID = ec.SongID
ORDER BY s.AppleChartsPosition;


-- ---------------------------------------------------------------------
-- 4) Total song count per artist (main artist + collaborator) — WINDOW FUNCTION
-- ---------------------------------------------------------------------
WITH AllAppearances AS (
    SELECT ArtistID, SongID FROM Songs
    UNION ALL
    SELECT ArtistID, SongID FROM Collabs
)
SELECT
    a.Name AS Artist,
    COUNT(*) AS TotalAppearances,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS PopularityRank
FROM AllAppearances aa
JOIN Artists a ON aa.ArtistID = a.ArtistID
GROUP BY a.Name
ORDER BY TotalAppearances DESC;


-- ---------------------------------------------------------------------
-- 5) Artist percentage by country — WINDOW FUNCTION
-- ---------------------------------------------------------------------
SELECT
    Country,
    COUNT(*) AS ArtistCount,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS Percentage
FROM Artists
GROUP BY Country
ORDER BY ArtistCount DESC;


-- ---------------------------------------------------------------------
-- 5b) CORRECT collaboration percentage — based on unique song count
-- ---------------------------------------------------------------------
-- NOTE: the Collabs table has 2 rows for "Like That" (SongID=8)
-- (2 different collaborators: Metro Boomin and Kendrick Lamar). Using
-- COUNT(*) counts this row count and mistakenly gives 25%. The correct
-- approach is to use COUNT(DISTINCT SongID) to get the unique song count (20%).
SELECT
    COUNT(DISTINCT SongID) AS UniqueCollabSongs,
    (SELECT COUNT(*) FROM Songs) AS TotalSongs,
    ROUND(COUNT(DISTINCT SongID) * 100.0 / (SELECT COUNT(*) FROM Songs), 1) AS CollabPercentage
FROM Collabs;

-- ---------------------------------------------------------------------
-- 5c) Gender distribution — two different metrics (artist-based vs. song-based)
-- ---------------------------------------------------------------------
-- Artist-based: gender distribution among 21 unique artists (71% Male / 29% Female)
SELECT
    Gender,
    COUNT(*) AS ArtistCount,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS Percentage
FROM Artists
GROUP BY Gender;

-- Song-based: based on the main artist's gender for each of the 20 songs
-- (65% Male / 35% Female). This differs from the artist-based ratio because
-- Sabrina Carpenter and Taylor Swift each have 2 songs.
SELECT
    a.Gender,
    COUNT(*) AS SongCount,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS Percentage
FROM Songs s
JOIN Artists a ON s.ArtistID = a.ArtistID
GROUP BY a.Gender;


-- ---------------------------------------------------------------------
-- 6) Reusable report: creating a VIEW
-- ---------------------------------------------------------------------
-- This view returns song + artist + genre + explicit content information
-- in a single query, so there's no need to keep rewriting the same JOINs.
CREATE OR REPLACE VIEW SongFullReport AS
SELECT
    s.AppleChartsPosition,
    s.Title AS Song,
    a.Name AS Artist,
    a.Country,
    g.Genre,
    s.Duration,
    IF(ec.SongID IS NOT NULL, 'Yes', 'No') AS ExclusiveContent
FROM Songs s
JOIN Artists a ON s.ArtistID = a.ArtistID
LEFT JOIN Genres g ON s.SongID = g.SongID
LEFT JOIN ExclusiveContent ec ON s.SongID = ec.SongID;

-- Usage example:
SELECT * FROM SongFullReport ORDER BY AppleChartsPosition;

-- Average duration (from v1)
SELECT SEC_TO_TIME(AVG(TIME_TO_SEC(Duration))) AS AverageDuration FROM Songs;
