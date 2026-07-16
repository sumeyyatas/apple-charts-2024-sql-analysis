import pandas as pd
import matplotlib.pyplot as plt

plt.rcParams["font.family"] = "DejaVu Sans"

# ---- Data (aynı SQL verisinden) ----
artists = pd.DataFrame([
    (1,'Kendrick Lamar','Male','USA'),(2,'Taylor Swift','Female','USA'),
    (3,'Billie Eilish','Female','USA'),(4,'Benson Boone','Male','USA'),
    (5,'Sabrina Carpenter','Female','USA'),(6,'Shaboozey','Male','USA'),
    (7,'Post Malone','Male','USA'),(8,'Teddy Swims','Male','USA'),
    (9,'Metro Boomin','Male','USA'),(10,'Future','Male','USA'),
    (11,'Creepy Nuts','Male','Japan'),(12,'SZA','Female','USA'),
    (13,'Morgan Wallen','Male','USA'),(14,'Noah Kahan','Male','USA'),
    (15,'Jack Harlow','Male','USA'),(16,'Zach Bryan','Male','USA'),
    (17,'Hozier','Male','Ireland'),(18,'Tate McRae','Female','Canada'),
    (19,'Tommy Richman','Male','USA'),(20,'Lil Baby','Male','USA'),
    (21,'Kacey Musgraves','Female','USA'),
], columns=['ArtistID','Name','Gender','Country'])

songs = pd.DataFrame([
    ('Not Like Us',1,1),('Beautiful Things',4,2),('Espresso',5,3),
    ('A Bar Song',6,4),('Cruel Summer',2,5),('I Had Some Help',7,6),
    ('Lose Control',8,7),('Like That',10,8),('Birds Of A Feather',3,9),
    ('Bling-Bang-Bang-Born',11,10),('Snooze',12,11),('Last Night',13,12),
    ('Stick Season',14,13),('Lovin On Me',15,14),('I Remember Everything',16,15),
    ('Please Please Please',5,16),('Too Sweet',17,17),('Greedy',18,18),
    ('Millon Dollar Baby',19,19),('Fortnight',2,20),
], columns=['Title','ArtistID','AppleChartsPosition'])

genres = pd.DataFrame([
    (1,'Hip-Hop'),(2,'Pop'),(3,'Pop'),(4,'Country'),(5,'Pop'),(6,'Country'),
    (7,'Rock'),(8,'Hip-Hop'),(9,'Pop'),(10,'Hip-Hop'),(11,'R&B'),(12,'Country'),
    (13,'Alternative'),(14,'Hip-Hop'),(15,'Country'),(16,'Pop'),(17,'Alternative'),
    (18,'Pop'),(19,'R&B'),(20,'Pop'),
], columns=['SongPos','Genre'])

exclusive_ids = {1,3,4,6,8,11,12,14,16,18}  # AppleChartsPosition bazlı

COLORS = ['#5B8FF9','#61DDAA','#F6BD16','#F6903D','#E8684A','#6DC8EC','#9270CA']

# Tek bir dashboard görseli — 4 grafik 2x2 grid halinde
fig, axes = plt.subplots(2, 2, figsize=(13, 10))
fig.suptitle("Apple Charts 2024 — Top 20 Şarkı Analizi", fontsize=16, fontweight='bold', y=0.98)

# 1) Genre distribution (top-left)
ax = axes[0, 0]
genre_counts = genres['Genre'].value_counts()
ax.barh(genre_counts.index[::-1], genre_counts.values[::-1], color=COLORS[0])
ax.set_title("Tür Dağılımı", fontsize=12, fontweight='bold')
ax.set_xlabel("Şarkı Sayısı")
for i, v in enumerate(genre_counts.values[::-1]):
    ax.text(v + 0.05, i, str(v), va='center', fontsize=9)

# 2) Gender distribution (top-right) — sanatçı bazlı
ax = axes[0, 1]
gender_counts = artists['Gender'].value_counts()
ax.pie(gender_counts.values, labels=gender_counts.index, autopct='%1.0f%%',
       colors=['#5B8FF9', '#F6BD16'], startangle=90, textprops={'fontsize': 10})
ax.set_title("Cinsiyet Dağılımı (sanatçı bazlı)", fontsize=12, fontweight='bold')

# 3) Country distribution (bottom-left)
ax = axes[1, 0]
country_counts = artists['Country'].value_counts()
ax.pie(country_counts.values, labels=country_counts.index, autopct='%1.0f%%',
       colors=COLORS, startangle=90, textprops={'fontsize': 10})
ax.set_title("Ülkelere Göre Dağılım", fontsize=12, fontweight='bold')

# 4) Exclusive content (bottom-right)
ax = axes[1, 1]
exclusive_flags = songs['AppleChartsPosition'].apply(lambda x: 'Yes' if x in exclusive_ids else 'No')
exc_counts = exclusive_flags.value_counts()
ax.pie(exc_counts.values, labels=exc_counts.index, autopct='%1.0f%%',
       colors=['#61DDAA', '#E8684A'], startangle=90, textprops={'fontsize': 10})
ax.set_title("Sansürsüz İçerik Oranı", fontsize=12, fontweight='bold')

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig("charts_dashboard.png", dpi=150)
plt.close()

print("Dashboard grafiği oluşturuldu: charts_dashboard.png")
