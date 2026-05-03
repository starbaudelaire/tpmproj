const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
const slugify = require('slugify');
const prisma = new PrismaClient();
const destinations = [
  [
    "Keraton Yogyakarta",
    "CULTURE",
    "heritage",
    -7.8053,
    110.3642,
    "Pusat kebudayaan Kesultanan Yogyakarta dan simbol sejarah kota.",
    "Jl. Rotowijayan, Kraton",
    "budaya,sejarah,keraton",
    5
  ],
  [
    "Taman Sari",
    "CULTURE",
    "heritage",
    -7.8101,
    110.3594,
    "Kompleks taman kerajaan dengan kolam, lorong, dan arsitektur unik.",
    "Patehan, Kraton",
    "sejarah,arsitektur,heritage",
    5
  ],
  [
    "Museum Sonobudoyo",
    "CULTURE",
    "museum",
    -7.8038,
    110.3633,
    "Museum budaya Jawa dengan koleksi wayang, keris, batik, dan naskah.",
    "Jl. Pangurakan",
    "museum,budaya,edukasi",
    5
  ],
  [
    "Museum Benteng Vredeburg",
    "CULTURE",
    "museum",
    -7.8002,
    110.3668,
    "Museum sejarah perjuangan Indonesia di bangunan benteng kolonial.",
    "Jl. Margo Mulyo",
    "museum,sejarah,edukasi",
    4
  ],
  [
    "Kotagede",
    "CULTURE",
    "heritage",
    -7.8281,
    110.3984,
    "Kawasan bersejarah Mataram Islam dan sentra kerajinan perak.",
    "Kotagede",
    "heritage,perak,sejarah",
    5
  ],
  [
    "Masjid Gedhe Kauman",
    "CULTURE",
    "religi",
    -7.8033,
    110.3627,
    "Masjid bersejarah di kawasan Kauman yang lekat dengan Kesultanan.",
    "Kauman, Kraton",
    "religi,sejarah,budaya",
    5
  ],
  [
    "Kampung Wisata Tamansari",
    "CULTURE",
    "kampung wisata",
    -7.8108,
    110.3577,
    "Kampung budaya di sekitar Tamansari dengan mural, batik, dan kerajinan.",
    "Patehan, Kraton",
    "kampung,budaya,kerajinan",
    4
  ],
  [
    "Kampung Wisata Dipowinatan",
    "CULTURE",
    "kampung wisata",
    -7.8094,
    110.3735,
    "Kampung wisata kota dengan aktivitas budaya dan kehidupan lokal.",
    "Keparakan, Mergangsan",
    "kampung,budaya,lokal",
    4
  ],
  [
    "Museum Ullen Sentalu",
    "CULTURE",
    "museum",
    -7.5967,
    110.4233,
    "Museum seni dan budaya Jawa dengan narasi keluarga kerajaan.",
    "Kaliurang, Sleman",
    "museum,jawa,edukasi",
    5
  ],
  [
    "Museum Affandi",
    "CULTURE",
    "museum",
    -7.7828,
    110.3964,
    "Museum seni yang menampilkan karya dan kediaman Affandi.",
    "Jl. Laksda Adisucipto",
    "museum,seni,lukisan",
    4
  ],
  [
    "Museum Dirgantara Mandala",
    "CULTURE",
    "museum",
    -7.7889,
    110.4318,
    "Museum sejarah penerbangan Indonesia dengan koleksi pesawat.",
    "Kompleks Lanud Adisutjipto",
    "museum,edukasi,pesawat",
    3
  ],
  [
    "Museum Wayang Kekayon",
    "CULTURE",
    "museum",
    -7.8297,
    110.4148,
    "Museum wayang dengan koleksi budaya pewayangan Nusantara.",
    "Banguntapan, Bantul",
    "museum,wayang,budaya",
    4
  ],
  [
    "Desa Wisata Kasongan",
    "CULTURE",
    "desa wisata",
    -7.8468,
    110.3423,
    "Sentra gerabah dan kerajinan tanah liat khas Bantul.",
    "Kasongan, Bantul",
    "desa-wisata,gerabah,kerajinan",
    4
  ],
  [
    "Desa Wisata Krebet",
    "CULTURE",
    "desa wisata",
    -7.886,
    110.2949,
    "Desa wisata batik kayu dengan suasana pedesaan Bantul.",
    "Sendangsari, Bantul",
    "desa-wisata,batik-kayu,kerajinan",
    4
  ],
  [
    "Desa Wisata Manding",
    "CULTURE",
    "desa wisata",
    -7.8826,
    110.3408,
    "Sentra kerajinan kulit untuk tas, sepatu, dan aksesori.",
    "Manding, Bantul",
    "kerajinan,kulit,desa-wisata",
    3
  ],
  [
    "Desa Wisata Tembi",
    "CULTURE",
    "desa wisata",
    -7.8726,
    110.3546,
    "Desa wisata budaya dengan nuansa pedesaan dan seni tradisi.",
    "Timbulharjo, Bantul",
    "desa-wisata,budaya,tradisi",
    4
  ],
  [
    "Desa Wisata Pentingsari",
    "CULTURE",
    "desa wisata",
    -7.6339,
    110.4307,
    "Desa wisata lereng Merapi dengan aktivitas edukasi dan budaya lokal.",
    "Cangkringan, Sleman",
    "desa-wisata,alam,budaya",
    4
  ],
  [
    "Desa Wisata Brayut",
    "CULTURE",
    "desa wisata",
    -7.7004,
    110.3702,
    "Desa wisata dengan pengalaman kehidupan desa dan tradisi agraris.",
    "Pandowoharjo, Sleman",
    "desa-wisata,tradisi,edukasi",
    4
  ],
  [
    "Sendratari Ramayana Prambanan",
    "CULTURE",
    "pertunjukan",
    -7.7526,
    110.4918,
    "Pertunjukan seni tari yang mengangkat kisah Ramayana di area Prambanan.",
    "Prambanan, Sleman",
    "tari,budaya,pertunjukan",
    5
  ],
  [
    "Padepokan Seni Bagong Kussudiardja",
    "CULTURE",
    "seni",
    -7.8753,
    110.3551,
    "Ruang seni dan budaya yang aktif mendukung pertunjukan serta edukasi.",
    "Bantul",
    "seni,budaya,pertunjukan",
    4
  ],
  [
    "Malioboro",
    "TOURISM",
    "ikon kota",
    -7.7926,
    110.3658,
    "Koridor ikonik Jogja untuk jalan kaki, belanja, dan menikmati suasana kota.",
    "Jl. Malioboro",
    "ikon,belanja,jalan-kaki",
    4
  ],
  [
    "Tugu Yogyakarta",
    "TOURISM",
    "ikon kota",
    -7.7829,
    110.3671,
    "Landmark kota yang menjadi simbol filosofi dan orientasi Jogja.",
    "Jetis, Yogyakarta",
    "ikon,foto,sejarah",
    4
  ],
  [
    "Alun-Alun Kidul",
    "TOURISM",
    "ikon kota",
    -7.8117,
    110.3634,
    "Ruang publik selatan Keraton yang populer saat malam.",
    "Kraton, Yogyakarta",
    "malam,keluarga,ikon",
    4
  ],
  [
    "Alun-Alun Utara",
    "TOURISM",
    "ikon kota",
    -7.8022,
    110.3645,
    "Ruang publik bersejarah di depan Keraton Yogyakarta.",
    "Kraton, Yogyakarta",
    "sejarah,ikon,kota",
    4
  ],
  [
    "Candi Prambanan",
    "TOURISM",
    "candi",
    -7.752,
    110.4915,
    "Kompleks candi Hindu megah yang menjadi ikon warisan budaya.",
    "Bokoharjo, Sleman",
    "candi,sejarah,unesco",
    5
  ],
  [
    "Candi Ratu Boko",
    "TOURISM",
    "candi",
    -7.7705,
    110.4894,
    "Situs istana kuno dengan panorama senja yang populer.",
    "Bokoharjo, Sleman",
    "candi,sunset,sejarah",
    4
  ],
  [
    "Candi Ijo",
    "TOURISM",
    "candi",
    -7.7838,
    110.5119,
    "Candi di ketinggian dengan pemandangan luas ke arah Jogja.",
    "Sambirejo, Sleman",
    "candi,sunset,view",
    4
  ],
  [
    "Candi Sambisari",
    "TOURISM",
    "candi",
    -7.7625,
    110.4471,
    "Candi yang berada lebih rendah dari permukaan tanah sekitar.",
    "Kalasan, Sleman",
    "candi,sejarah,edukasi",
    4
  ],
  [
    "Candi Plaosan",
    "TOURISM",
    "candi",
    -7.7409,
    110.5045,
    "Kompleks candi kembar dengan suasana tenang di dekat Prambanan.",
    "Bugisan, Klaten/Yogya sekitar",
    "candi,sejarah,foto",
    4
  ],
  [
    "Tebing Breksi",
    "TOURISM",
    "alam",
    -7.7815,
    110.5046,
    "Bekas tambang batu yang menjadi destinasi tebing artistik dan panorama Jogja.",
    "Sambirejo, Sleman",
    "alam,tebing,panorama",
    3
  ],
  [
    "Obelix Hills",
    "TOURISM",
    "viewpoint",
    -7.8222,
    110.4931,
    "Area rekreasi perbukitan dengan pemandangan dan spot foto.",
    "Prambanan, Sleman",
    "view,foto,sunset",
    2
  ],
  [
    "HeHa Sky View",
    "TOURISM",
    "viewpoint",
    -7.8497,
    110.4788,
    "Tempat menikmati panorama kota dari perbukitan dengan area foto.",
    "Patuk, Gunungkidul",
    "view,modern,foto",
    2
  ],
  [
    "HeHa Ocean View",
    "TOURISM",
    "pantai",
    -8.136,
    110.579,
    "Destinasi pemandangan laut selatan dengan spot foto modern.",
    "Panggang, Gunungkidul",
    "pantai,view,foto",
    2
  ],
  [
    "Pantai Parangtritis",
    "TOURISM",
    "pantai",
    -8.0255,
    110.3292,
    "Pantai legendaris dengan gumuk pasir dan suasana pesisir selatan.",
    "Kretek, Bantul",
    "pantai,legenda,sunset",
    4
  ],
  [
    "Gumuk Pasir Parangkusumo",
    "TOURISM",
    "alam",
    -8.0159,
    110.3166,
    "Bentang pasir unik untuk foto dan aktivitas sandboarding.",
    "Parangtritis, Bantul",
    "alam,pasir,foto",
    3
  ],
  [
    "Pantai Depok",
    "TOURISM",
    "pantai",
    -8.0147,
    110.2939,
    "Pantai dengan suasana kuliner laut dan aktivitas nelayan.",
    "Bantul",
    "pantai,seafood,keluarga",
    3
  ],
  [
    "Pantai Indrayanti",
    "TOURISM",
    "pantai",
    -8.1503,
    110.6124,
    "Pantai pasir putih Gunungkidul dengan fasilitas wisata lengkap.",
    "Tepus, Gunungkidul",
    "pantai,laut,foto",
    3
  ],
  [
    "Pantai Timang",
    "TOURISM",
    "pantai",
    -8.1767,
    110.6624,
    "Pantai karang dengan gondola tradisional menuju pulau kecil.",
    "Purwodadi, Gunungkidul",
    "pantai,adventure,karang",
    3
  ],
  [
    "Pantai Sadranan",
    "TOURISM",
    "pantai",
    -8.1451,
    110.6048,
    "Pantai pasir putih yang dikenal untuk snorkeling ringan.",
    "Tepus, Gunungkidul",
    "pantai,snorkeling,keluarga",
    3
  ],
  [
    "Pantai Ngobaran",
    "TOURISM",
    "pantai",
    -8.1198,
    110.505,
    "Pantai dengan nuansa budaya dan bangunan ibadah di tepi laut.",
    "Saptosari, Gunungkidul",
    "pantai,budaya,foto",
    4
  ],
  [
    "Pantai Ngrenehan",
    "TOURISM",
    "pantai",
    -8.1215,
    110.5144,
    "Pantai teluk kecil dengan aktivitas nelayan dan kuliner laut.",
    "Saptosari, Gunungkidul",
    "pantai,nelayan,seafood",
    3
  ],
  [
    "Pantai Wediombo",
    "TOURISM",
    "pantai",
    -8.1851,
    110.7067,
    "Pantai luas dengan lanskap karang dan suasana alami.",
    "Girisubo, Gunungkidul",
    "pantai,alam,karang",
    3
  ],
  [
    "Pantai Pok Tunggal",
    "TOURISM",
    "pantai",
    -8.1559,
    110.6214,
    "Pantai pasir putih yang dikenal dengan pohon ikoniknya.",
    "Tepus, Gunungkidul",
    "pantai,foto,hidden-gem",
    3
  ],
  [
    "Hutan Pinus Mangunan",
    "TOURISM",
    "alam",
    -7.9263,
    110.4317,
    "Kawasan hutan pinus dengan spot foto dan udara sejuk.",
    "Mangunan, Bantul",
    "alam,hutan,foto",
    3
  ],
  [
    "Kebun Buah Mangunan",
    "TOURISM",
    "alam",
    -7.9407,
    110.4248,
    "Viewpoint perbukitan dengan pemandangan kabut pagi Sungai Oya.",
    "Mangunan, Bantul",
    "alam,viewpoint,pagi",
    3
  ],
  [
    "Puncak Becici",
    "TOURISM",
    "alam",
    -7.9027,
    110.4268,
    "Hutan pinus dan gardu pandang populer untuk menikmati senja.",
    "Muntuk, Bantul",
    "alam,sunset,hutan",
    3
  ],
  [
    "Jurang Tembelan",
    "TOURISM",
    "alam",
    -7.9374,
    110.426,
    "Spot pandang perbukitan dengan panorama Sungai Oya.",
    "Mangunan, Bantul",
    "view,alam,foto",
    3
  ],
  [
    "Seribu Batu Songgo Langit",
    "TOURISM",
    "alam",
    -7.9312,
    110.4325,
    "Destinasi hutan dan spot foto tematik di kawasan Mangunan.",
    "Mangunan, Bantul",
    "hutan,foto,keluarga",
    3
  ],
  [
    "Goa Pindul",
    "TOURISM",
    "alam",
    -7.9313,
    110.6518,
    "Wisata susur gua dengan aliran sungai bawah tanah.",
    "Bejiharjo, Gunungkidul",
    "gua,petualangan,alam",
    3
  ],
  [
    "Kalisuci Cave Tubing",
    "TOURISM",
    "alam",
    -7.9407,
    110.6374,
    "Aktivitas cave tubing dengan aliran sungai karst.",
    "Semanu, Gunungkidul",
    "gua,adventure,alam",
    3
  ],
  [
    "Gunung Api Purba Nglanggeran",
    "TOURISM",
    "alam",
    -7.8413,
    110.5439,
    "Kawasan geowisata dengan jalur pendakian ringan dan desa wisata.",
    "Nglanggeran, Gunungkidul",
    "gunung,desa-wisata,alam",
    4
  ],
  [
    "Embung Nglanggeran",
    "TOURISM",
    "alam",
    -7.845,
    110.5455,
    "Embung di perbukitan yang cocok untuk menikmati suasana pagi atau senja.",
    "Nglanggeran, Gunungkidul",
    "embung,view,alam",
    3
  ],
  [
    "Kaliurang",
    "TOURISM",
    "alam",
    -7.5965,
    110.4241,
    "Kawasan wisata lereng Merapi dengan udara sejuk.",
    "Pakem, Sleman",
    "merapi,sejuk,alam",
    3
  ],
  [
    "Lava Tour Merapi",
    "TOURISM",
    "adventure",
    -7.5848,
    110.447,
    "Tur jip di kawasan bekas erupsi Merapi dengan lanskap vulkanik.",
    "Cangkringan, Sleman",
    "merapi,adventure,jip",
    3
  ],
  [
    "The Lost World Castle",
    "TOURISM",
    "rekreasi",
    -7.6037,
    110.4555,
    "Destinasi tematik di kawasan lereng Merapi untuk foto dan rekreasi.",
    "Cangkringan, Sleman",
    "foto,merapi,keluarga",
    2
  ],
  [
    "Merapi Park",
    "TOURISM",
    "rekreasi",
    -7.6172,
    110.4212,
    "Taman rekreasi dengan miniatur landmark dan area keluarga.",
    "Kaliurang, Sleman",
    "keluarga,foto,taman",
    2
  ],
  [
    "Taman Pelangi Monjali",
    "TOURISM",
    "malam",
    -7.7484,
    110.3693,
    "Taman lampion malam di area Monumen Jogja Kembali.",
    "Sleman",
    "malam,lampion,keluarga",
    2
  ],
  [
    "Sindu Kusuma Edupark",
    "TOURISM",
    "rekreasi",
    -7.7674,
    110.3541,
    "Wahana rekreasi keluarga di sisi barat kota Yogyakarta.",
    "Mlati, Sleman",
    "keluarga,wahana,rekreasi",
    2
  ],
  [
    "Gembira Loka Zoo",
    "TOURISM",
    "edukasi",
    -7.8062,
    110.3963,
    "Kebun binatang kota untuk rekreasi dan edukasi keluarga.",
    "Kotagede/Umbulharjo",
    "keluarga,edukasi,zoo",
    3
  ],
  [
    "Taman Pintar Yogyakarta",
    "TOURISM",
    "edukasi",
    -7.8009,
    110.3672,
    "Tempat belajar interaktif sains dan edukasi untuk keluarga.",
    "Jl. Panembahan Senopati",
    "edukasi,keluarga,sains",
    3
  ],
  [
    "Gudeg Yu Djum Wijilan",
    "CULINARY",
    "gudeg",
    -7.8059,
    110.3664,
    "Gudeg legendaris khas Jogja di kawasan Wijilan.",
    "Wijilan, Yogyakarta",
    "gudeg,legendaris,kuliner",
    5
  ],
  [
    "Gudeg Pawon",
    "CULINARY",
    "gudeg",
    -7.8022,
    110.3883,
    "Gudeg malam yang disajikan langsung dari pawon atau dapur.",
    "Janturan, Yogyakarta",
    "gudeg,malam,lokal",
    5
  ],
  [
    "Gudeg Permata",
    "CULINARY",
    "gudeg",
    -7.8,
    110.37,
    "Gudeg malam populer dengan cita rasa klasik Jogja.",
    "Yogyakarta",
    "gudeg,malam,legendaris",
    4
  ],
  [
    "Gudeg Sagan",
    "CULINARY",
    "gudeg",
    -7.7795,
    110.3786,
    "Pilihan gudeg populer di area Sagan dan kampus.",
    "Sagan, Yogyakarta",
    "gudeg,kuliner,lokal",
    4
  ],
  [
    "Sate Klathak Pak Pong",
    "CULINARY",
    "sate",
    -7.8667,
    110.3866,
    "Sate kambing khas Bantul dengan tusuk jeruji dan bumbu sederhana.",
    "Wonokromo, Bantul",
    "sate,legendaris,bantul",
    4
  ],
  [
    "Sate Klathak Pak Bari",
    "CULINARY",
    "sate",
    -7.8675,
    110.3861,
    "Sate klathak populer di kawasan Imogiri.",
    "Wonokromo, Bantul",
    "sate,kambing,lokal",
    4
  ],
  [
    "Bakmi Jawa Mbah Gito",
    "CULINARY",
    "bakmi jawa",
    -7.8148,
    110.3872,
    "Bakmi Jawa dengan suasana rumah kayu tradisional.",
    "Jl. Nyi Ageng Nis",
    "bakmi,jawa,tradisional",
    4
  ],
  [
    "Bakmi Kadin",
    "CULINARY",
    "bakmi jawa",
    -7.8025,
    110.3763,
    "Bakmi Jawa legendaris dekat pusat kota.",
    "Bintaran, Yogyakarta",
    "bakmi,jawa,legendaris",
    4
  ],
  [
    "Bakmi Pele",
    "CULINARY",
    "bakmi jawa",
    -7.8118,
    110.3636,
    "Bakmi Jawa malam yang populer di sekitar Alun-Alun Kidul.",
    "Kraton, Yogyakarta",
    "bakmi,malam,lokal",
    4
  ],
  [
    "Kopi Klotok",
    "CULINARY",
    "kuliner desa",
    -7.6411,
    110.4249,
    "Warung bernuansa pedesaan dengan kopi, pisang goreng, dan sayur lodeh.",
    "Pakem, Sleman",
    "kopi,desa,sarapan",
    4
  ],
  [
    "Angkringan Lik Man",
    "CULINARY",
    "angkringan",
    -7.7898,
    110.3636,
    "Angkringan legendaris dengan kopi joss dekat Tugu Jogja.",
    "Jl. Wongsodirjan",
    "angkringan,kopi-joss,malam",
    4
  ],
  [
    "House of Raminten",
    "CULINARY",
    "resto budaya",
    -7.7828,
    110.3707,
    "Restoran bernuansa Jawa kontemporer dengan menu lokal.",
    "Kotabaru, Yogyakarta",
    "kuliner,budaya,resto",
    4
  ],
  [
    "Soto Kadipiro",
    "CULINARY",
    "soto",
    -7.8018,
    110.3454,
    "Soto legendaris Jogja dengan cita rasa klasik.",
    "Jl. Wates",
    "soto,legendaris,sarapan",
    4
  ],
  [
    "Soto Bathok Mbah Katro",
    "CULINARY",
    "soto",
    -7.758,
    110.442,
    "Soto bathok populer dengan suasana pedesaan.",
    "Sambisari, Sleman",
    "soto,sarapan,desa",
    4
  ],
  [
    "Mangut Lele Mbah Marto",
    "CULINARY",
    "mangut",
    -7.8624,
    110.3375,
    "Mangut lele pedas khas Bantul dengan suasana rumahan.",
    "Sewon, Bantul",
    "mangut,pedas,tradisional",
    4
  ],
  [
    "Brongkos Handayani",
    "CULINARY",
    "brongkos",
    -7.8037,
    110.3634,
    "Brongkos klasik dekat kawasan Alun-Alun Kidul.",
    "Kraton, Yogyakarta",
    "brongkos,tradisional,kuliner",
    4
  ],
  [
    "Oseng Mercon Bu Narti",
    "CULINARY",
    "pedas",
    -7.8005,
    110.3611,
    "Kuliner pedas khas Jogja yang populer untuk makan malam.",
    "Ngampilan, Yogyakarta",
    "pedas,malam,lokal",
    4
  ],
  [
    "Mie Lethek Mbah Mendes",
    "CULINARY",
    "mie lethek",
    -7.8208,
    110.3671,
    "Olahan mie lethek khas Bantul dengan nuansa tradisional.",
    "Yogyakarta/Bantul",
    "mie-lethek,tradisional,lokal",
    3
  ],
  [
    "Jejamuran",
    "CULINARY",
    "resto keluarga",
    -7.7065,
    110.3691,
    "Restoran dengan berbagai olahan jamur untuk keluarga.",
    "Pandowoharjo, Sleman",
    "jamur,keluarga,resto",
    3
  ],
  [
    "Wedang Ronde Mbah Payem",
    "CULINARY",
    "minuman tradisional",
    -7.7859,
    110.3674,
    "Wedang ronde hangat yang cocok untuk malam hari di Jogja.",
    "Yogyakarta",
    "wedang,malam,tradisional",
    3
  ],
  [
    "Tempo Gelato Prawirotaman",
    "CULINARY",
    "gelato",
    -7.8198,
    110.3719,
    "Gelato populer di kawasan Prawirotaman.",
    "Prawirotaman, Yogyakarta",
    "gelato,modern,santai",
    2
  ],
  [
    "Warung Bu Ageng",
    "CULINARY",
    "masakan jawa",
    -7.821,
    110.3717,
    "Warung masakan rumahan bernuansa Jawa.",
    "Prawirotaman, Yogyakarta",
    "jawa,rumahan,kuliner",
    3
  ],
  [
    "Sego Koyor Bu Parman",
    "CULINARY",
    "nasi koyor",
    -7.7899,
    110.3625,
    "Kuliner malam lokal dengan menu nasi koyor.",
    "Yogyakarta",
    "malam,lokal,pedas",
    3
  ],
  [
    "Lumpia Samijaya",
    "CULINARY",
    "jajanan",
    -7.7927,
    110.3656,
    "Jajanan lumpia populer di area Malioboro.",
    "Malioboro, Yogyakarta",
    "jajanan,malioboro,lokal",
    3
  ],
  [
    "Bakpia Pathok 25",
    "CULINARY",
    "oleh-oleh",
    -7.7903,
    110.3578,
    "Bakpia populer sebagai oleh-oleh khas Jogja.",
    "Pathuk, Yogyakarta",
    "bakpia,oleh-oleh,khas",
    3
  ],
  [
    "Yangko Pak Prapto",
    "CULINARY",
    "oleh-oleh",
    -7.8089,
    110.3852,
    "Jajanan tradisional yangko khas Kotagede.",
    "Kotagede, Yogyakarta",
    "yangko,oleh-oleh,tradisional",
    3
  ],
  [
    "Geplak Bantul",
    "CULINARY",
    "oleh-oleh",
    -7.888,
    110.329,
    "Kudapan manis tradisional khas Bantul.",
    "Bantul",
    "geplak,oleh-oleh,tradisional",
    3
  ],
  [
    "Pasar Beringharjo",
    "CULINARY",
    "pasar tradisional",
    -7.7986,
    110.3671,
    "Pasar tradisional untuk kuliner, batik, dan suasana lokal.",
    "Malioboro, Yogyakarta",
    "pasar,batik,kuliner",
    4
  ],
  [
    "Pasar Kotagede",
    "CULINARY",
    "pasar tradisional",
    -7.8292,
    110.3991,
    "Pasar tradisional di kawasan Kotagede dengan jajanan lokal.",
    "Kotagede, Yogyakarta",
    "pasar,jajanan,lokal",
    3
  ],
  [
    "Pasar Sentul",
    "CULINARY",
    "pasar tradisional",
    -7.7976,
    110.3787,
    "Pasar tradisional yang bisa menjadi titik eksplorasi kuliner lokal.",
    "Pakualaman, Yogyakarta",
    "pasar,kuliner,lokal",
    3
  ],
  [
    "Kraton Resto",
    "CULINARY",
    "resto budaya",
    -7.8063,
    110.3663,
    "Restoran di sekitar kawasan budaya Kraton.",
    "Kraton, Yogyakarta",
    "resto,budaya,kuliner",
    3
  ],
  [
    "Nasi Teri Gejayan",
    "CULINARY",
    "nasi",
    -7.7717,
    110.391,
    "Kuliner sederhana populer di area mahasiswa.",
    "Gejayan, Sleman",
    "nasi,mahasiswa,lokal",
    2
  ],
  [
    "Lotek Teteg",
    "CULINARY",
    "lotek",
    -7.789,
    110.362,
    "Lotek dan gado-gado lokal yang dikenal di area Tugu.",
    "Yogyakarta",
    "lotek,sayur,lokal",
    3
  ],
  [
    "Pecel Senggol Beringharjo",
    "CULINARY",
    "pecel",
    -7.7989,
    110.3673,
    "Pecel pasar yang cocok untuk sarapan saat jelajah Malioboro.",
    "Beringharjo, Yogyakarta",
    "pecel,pasar,sarapan",
    3
  ],
  [
    "Es Buah PK",
    "CULINARY",
    "minuman",
    -7.7854,
    110.3773,
    "Es buah legendaris untuk menyegarkan siang hari.",
    "Pakuningratan/Kotabaru",
    "es,legendaris,siang",
    3
  ],
  [
    "SGPC Bu Wiryo",
    "CULINARY",
    "pecel",
    -7.7712,
    110.3774,
    "Sego pecel populer di kawasan kampus.",
    "UGM, Sleman",
    "pecel,sarapan,kampus",
    3
  ],
  [
    "Warung Kopi Klotok Kaliurang",
    "CULINARY",
    "kopi",
    -7.6411,
    110.4249,
    "Titik kuliner bernuansa desa di jalur Kaliurang.",
    "Pakem, Sleman",
    "kopi,desa,kaliurang",
    4
  ],
  [
    "Ingkung Kuali",
    "CULINARY",
    "ayam kampung",
    -7.8703,
    110.3257,
    "Kuliner ayam ingkung dengan cita rasa tradisional Jawa.",
    "Bantul",
    "ingkung,jawa,keluarga",
    3
  ],
  [
    "Sate Ratu",
    "CULINARY",
    "sate",
    -7.7607,
    110.4028,
    "Sate ayam modern yang populer di kalangan wisatawan.",
    "Sleman",
    "sate,modern,kuliner",
    2
  ],
  [
    "Warung Klangenan",
    "CULINARY",
    "masakan jawa",
    -7.7962,
    110.3708,
    "Warung dengan menu lokal dan suasana santai.",
    "Yogyakarta",
    "jawa,santai,kuliner",
    2
  ],
  [
    "Kedai Rakjat Djelata",
    "CULINARY",
    "resto lokal",
    -7.7823,
    110.3846,
    "Kedai lokal dengan pilihan menu Indonesia dan suasana kasual.",
    "Yogyakarta",
    "resto,lokal,santai",
    2
  ],
  [
    "Prawirotaman Street Food",
    "CULINARY",
    "street food",
    -7.8199,
    110.371,
    "Kawasan kuliner dan kafe yang ramai di area wisatawan.",
    "Prawirotaman, Yogyakarta",
    "street-food,kafe,malam",
    2
  ]
];
const quiz = [
  [
    "Mengapa Yogyakarta pernah menjadi ibu kota Republik Indonesia pada masa revolusi?",
    [
      "Karena Jakarta saat itu tidak aman setelah kedatangan kembali pasukan Belanda",
      "Karena Yogyakarta memiliki pelabuhan laut terbesar",
      "Karena semua negara asing berkedutaan di Yogyakarta",
      "Karena pusat industri nasional berada di Malioboro"
    ],
    0,
    "sejarah",
    "Pada 1946, pusat pemerintahan RI dipindahkan ke Yogyakarta karena situasi keamanan Jakarta tidak stabil. Jogja menjadi ruang penting bagi perjuangan diplomasi dan pemerintahan RI."
  ],
  [
    "Siapa Sultan Yogyakarta yang dikenal memberi dukungan besar kepada Republik Indonesia pada awal kemerdekaan?",
    [
      "Sri Sultan Hamengku Buwono IX",
      "Sri Sultan Hamengku Buwono I",
      "Ki Hadjar Dewantara",
      "Pangeran Diponegoro"
    ],
    0,
    "sejarah",
    "Sri Sultan Hamengku Buwono IX berperan penting mendukung Republik Indonesia, termasuk saat Yogyakarta menjadi pusat pemerintahan pada masa revolusi."
  ],
  [
    "Apa makna utama Serangan Umum 1 Maret 1949 bagi Yogyakarta dan Indonesia?",
    [
      "Membuktikan bahwa Republik Indonesia masih ada dan mampu melawan",
      "Meresmikan Malioboro sebagai pusat belanja",
      "Membuka jalur kereta pertama ke Yogyakarta",
      "Menjadikan Jogja sebagai pusat kuliner nasional"
    ],
    0,
    "sejarah",
    "Serangan Umum 1 Maret 1949 menunjukkan kepada dunia bahwa Republik Indonesia masih bertahan dan memiliki kekuatan perlawanan."
  ],
  [
    "Museum Benteng Vredeburg paling cocok dikunjungi wisatawan yang ingin mengenal apa?",
    [
      "Sejarah perjuangan Indonesia dalam suasana benteng kolonial",
      "Koleksi satwa liar pegunungan",
      "Teknologi pesawat modern",
      "Sejarah perkebunan teh"
    ],
    0,
    "destinasi",
    "Benteng Vredeburg menghadirkan cerita perjuangan dalam bangunan kolonial yang lokasinya strategis dekat Malioboro dan Titik Nol Kilometer."
  ],
  [
    "Mengapa Keraton Yogyakarta disebut sebagai pusat budaya hidup?",
    [
      "Karena masih menjalankan tradisi, upacara, tata nilai, dan aktivitas budaya",
      "Karena hanya menjadi tempat parkir wisatawan",
      "Karena berfungsi sebagai terminal bus",
      "Karena semua bangunannya berbentuk candi"
    ],
    0,
    "budaya",
    "Keraton bukan hanya bangunan bersejarah, tetapi pusat budaya yang masih hidup melalui adat, upacara, seni, dan tata nilai Jawa."
  ],
  [
    "Apa yang membuat Taman Sari menarik untuk wisata sejarah dan foto?",
    [
      "Kolam pemandian, lorong bawah tanah, dan arsitektur bekas taman kerajaan",
      "Arena permainan salju",
      "Menara pencakar langit modern",
      "Pelabuhan kapal besar"
    ],
    0,
    "destinasi",
    "Taman Sari menyimpan jejak taman kerajaan dengan kolam, lorong, dan arsitektur yang memberi suasana klasik khas Jogja."
  ],
  [
    "Apa yang identik dengan kawasan Kotagede?",
    [
      "Sejarah Mataram Islam dan kerajinan perak",
      "Wisata salju dan ski",
      "Tambang minyak bumi",
      "Pelabuhan internasional"
    ],
    0,
    "destinasi",
    "Kotagede dikenal sebagai kawasan bersejarah yang lekat dengan Mataram Islam dan tradisi kerajinan perak."
  ],
  [
    "Malioboro paling dikenal sebagai tempat untuk apa?",
    [
      "Jalan santai, belanja, kuliner, dan menikmati atmosfer kota Jogja",
      "Mendaki gunung berapi",
      "Melihat danau vulkanik",
      "Bermain ski air"
    ],
    0,
    "destinasi",
    "Malioboro adalah salah satu wajah wisata Jogja: ramai, hangat, mudah dijangkau, dan penuh pilihan belanja serta kuliner."
  ],
  [
    "Apa nama kawasan di sekitar pusat kota yang sering menjadi titik foto ikonik dekat Malioboro dan Vredeburg?",
    [
      "Titik Nol Kilometer",
      "Puncak Becici",
      "Pantai Baron",
      "Kaliurang Atas"
    ],
    0,
    "destinasi",
    "Titik Nol Kilometer menjadi ruang publik populer di pusat kota, dekat Gedung Agung, Vredeburg, dan Malioboro."
  ],
  [
    "Mengapa Tugu Jogja sering dianggap simbol penting kota?",
    [
      "Karena menjadi bagian dari sumbu filosofis dan ikon visual Yogyakarta",
      "Karena menjadi pintu masuk pelabuhan",
      "Karena merupakan bangunan stadion",
      "Karena tempat itu hanya dibuka saat lebaran"
    ],
    0,
    "filosofi",
    "Tugu Jogja adalah ikon kota yang sering dikaitkan dengan sumbu filosofis Yogyakarta dan menjadi penanda kuat identitas Jogja."
  ],
  [
    "Dalam sumbu filosofis Yogyakarta, Keraton berada dalam hubungan simbolik dengan apa?",
    [
      "Merapi, Tugu, Panggung Krapyak, dan Laut Selatan",
      "Bandara, terminal, dan stadion",
      "Pelabuhan, tambang, dan pabrik",
      "Danau, kebun teh, dan sawah garam"
    ],
    0,
    "filosofi",
    "Sumbu filosofis Yogyakarta menghubungkan lanskap, ruang kota, dan nilai budaya Jawa dalam satu rangkaian simbolik."
  ],
  [
    "Apa nilai yang sering diajarkan melalui budaya unggah-ungguh Jawa?",
    [
      "Sopan santun, penghormatan, dan kesadaran menempatkan diri",
      "Berbicara sekencang mungkin",
      "Mendahului semua orang tanpa antre",
      "Mengabaikan orang yang lebih tua"
    ],
    0,
    "budaya",
    "Unggah-ungguh adalah tata krama yang menekankan sopan santun, rasa hormat, dan kepekaan sosial."
  ],
  [
    "Blangkon dalam busana Jawa biasanya berfungsi sebagai apa?",
    [
      "Penutup kepala yang juga mencerminkan identitas dan kerapian pria Jawa",
      "Alat musik tiup",
      "Peralatan memasak gudeg",
      "Alas kaki untuk tari"
    ],
    0,
    "budaya",
    "Blangkon bukan sekadar penutup kepala, tetapi bagian dari tata busana tradisional Jawa yang memiliki nilai identitas dan kerapian."
  ],
  [
    "Apa yang membedakan batik sebagai warisan budaya, bukan sekadar kain bermotif?",
    [
      "Proses, motif, makna simbolik, dan tradisi pemakaiannya",
      "Karena selalu dibuat dari plastik",
      "Karena hanya boleh dipakai di pantai",
      "Karena tidak memiliki pola"
    ],
    0,
    "budaya",
    "Batik memiliki nilai pada proses pembuatan, motif, makna, serta tradisi yang hidup di masyarakat."
  ],
  [
    "Apa kuliner Jogja yang terkenal dengan rasa manis-gurih dari nangka muda?",
    [
      "Gudeg",
      "Rawon",
      "Pempek",
      "Papeda"
    ],
    0,
    "kuliner",
    "Gudeg dibuat dari nangka muda yang dimasak lama dengan santan dan bumbu, menghasilkan rasa manis-gurih khas Jogja."
  ],
  [
    "Apa lauk pelengkap gudeg yang terkenal pedas dan sering berwarna kemerahan?",
    [
      "Krecek",
      "Rendang",
      "Opor bebek hitam",
      "Sate lilit"
    ],
    0,
    "kuliner",
    "Sambal goreng krecek sering menemani gudeg dan memberi rasa pedas gurih yang menyeimbangkan manisnya gudeg."
  ],
  [
    "Bakpia Pathok dikenal sebagai apa bagi wisatawan Jogja?",
    [
      "Oleh-oleh khas yang populer",
      "Makanan pokok pengganti nasi",
      "Minuman rempah",
      "Jenis alat musik"
    ],
    0,
    "kuliner",
    "Bakpia, terutama yang berkembang dari kawasan Pathuk/Pathok, menjadi oleh-oleh yang sangat melekat dengan perjalanan ke Jogja."
  ],
  [
    "Apa yang membuat angkringan terasa khas dalam kehidupan Jogja?",
    [
      "Tempat makan sederhana yang juga menjadi ruang ngobrol lintas kalangan",
      "Restoran mewah yang wajib reservasi sebulan",
      "Tempat latihan militer",
      "Museum tertutup tanpa makanan"
    ],
    0,
    "kuliner",
    "Angkringan dikenal murah, akrab, dan menjadi ruang sosial tempat mahasiswa, warga, dan wisatawan saling berbaur."
  ],
  [
    "Apa minuman unik yang sering dikaitkan dengan angkringan dan diberi arang panas?",
    [
      "Kopi joss",
      "Es cendol",
      "Wedang uwuh dingin",
      "Jus alpukat"
    ],
    0,
    "kuliner",
    "Kopi joss terkenal karena penyajiannya menggunakan arang panas yang dimasukkan ke dalam kopi."
  ],
  [
    "Sate klathak khas Bantul terkenal karena apa?",
    [
      "Tusukan besi dan bumbu sederhana yang menonjolkan rasa daging kambing",
      "Kuah santan berwarna hijau",
      "Bahan utama ikan laut mentah",
      "Disajikan beku seperti es krim"
    ],
    0,
    "kuliner",
    "Sate klathak memakai tusukan besi dan bumbu sederhana, sehingga rasa daging kambingnya terasa kuat dan khas."
  ],
  [
    "Wedang uwuh cocok dikenalkan kepada wisatawan sebagai minuman apa?",
    [
      "Minuman rempah hangat khas Imogiri",
      "Soda dingin dari Eropa",
      "Minuman kopi instan",
      "Sup ikan laut"
    ],
    0,
    "kuliner",
    "Wedang uwuh adalah minuman rempah hangat yang populer dari kawasan Imogiri, cocok untuk suasana malam atau udara sejuk."
  ],
  [
    "Apa yang membuat Museum Sonobudoyo menarik bagi pencinta budaya?",
    [
      "Koleksi budaya Jawa seperti wayang, keris, batik, dan naskah",
      "Wahana roller coaster",
      "Akuarium laut raksasa",
      "Pusat belanja elektronik"
    ],
    0,
    "destinasi",
    "Museum Sonobudoyo menyimpan koleksi budaya Jawa yang kaya dan cocok untuk memahami akar budaya Yogyakarta."
  ],
  [
    "Museum Ullen Sentalu dikenal dengan daya tarik utama berupa apa?",
    [
      "Narasi budaya Jawa dan kisah keluarga kerajaan yang disajikan artistik",
      "Koleksi kapal selam",
      "Arena balap mobil",
      "Pasar hewan tradisional"
    ],
    0,
    "destinasi",
    "Ullen Sentalu dikenal karena cara bercerita yang kuat tentang budaya Jawa, seni, dan keluarga kerajaan."
  ],
  [
    "Candi Prambanan paling dikenal sebagai kompleks candi bercorak apa?",
    [
      "Hindu",
      "Islam",
      "Kristen",
      "Modern industrial"
    ],
    0,
    "destinasi",
    "Prambanan adalah kompleks candi Hindu besar yang menjadi salah satu ikon wisata budaya di kawasan Yogyakarta dan Jawa Tengah."
  ],
  [
    "Pertunjukan Ramayana Prambanan memadukan cerita epik dengan apa?",
    [
      "Tari, musik, dan latar megah kawasan candi",
      "Balap motor malam",
      "Kompetisi memasak",
      "Festival kapal"
    ],
    0,
    "budaya",
    "Sendratari Ramayana Prambanan memadukan seni tari, musik, dan cerita epik dengan suasana candi yang dramatis."
  ],
  [
    "Apa yang membuat Tebing Breksi populer sebagai destinasi wisata?",
    [
      "Tebing batu artistik, spot foto, dan pemandangan dari ketinggian",
      "Salju abadi",
      "Hutan bambu bawah laut",
      "Pusat industri tekstil"
    ],
    0,
    "destinasi",
    "Tebing Breksi menawarkan pahatan batu, lanskap terbuka, dan banyak spot foto yang cocok untuk wisata santai."
  ],
  [
    "Ratu Boko sering dinikmati wisatawan saat sore karena apa?",
    [
      "Pemandangan matahari terbenam dan suasana situs bersejarah",
      "Pertunjukan salju",
      "Pusat belanja grosir",
      "Pelabuhan kapal besar"
    ],
    0,
    "destinasi",
    "Ratu Boko sering dicari untuk menikmati sunset dengan latar situs bersejarah yang lapang dan fotogenik."
  ],
  [
    "Pantai Parangtritis dikenal sebagai pantai ikonik Jogja yang juga lekat dengan apa?",
    [
      "Cerita budaya Laut Selatan",
      "Tradisi ski salju",
      "Festival kapal pesiar Eropa",
      "Kawasan candi Buddha"
    ],
    0,
    "destinasi",
    "Parangtritis bukan hanya pantai populer, tetapi juga terkait dengan imajinasi budaya masyarakat tentang Laut Selatan."
  ],
  [
    "Gumuk Pasir Parangkusumo menarik karena menawarkan pengalaman seperti apa?",
    [
      "Lanskap pasir luas dan aktivitas sandboarding",
      "Menyelam di terumbu karang",
      "Bermain ski es",
      "Melihat perkebunan teh"
    ],
    0,
    "destinasi",
    "Gumuk Pasir Parangkusumo unik karena menghadirkan lanskap pasir luas dan aktivitas seperti sandboarding di dekat kawasan pantai."
  ],
  [
    "Apa yang sebaiknya dilakukan wisatawan saat berkunjung ke Keraton atau tempat budaya?",
    [
      "Berpakaian sopan dan mengikuti aturan setempat",
      "Berteriak di area sakral",
      "Menyentuh semua koleksi tanpa izin",
      "Membuang sampah sembarangan"
    ],
    0,
    "etika",
    "Tempat budaya perlu dihormati. Berpakaian sopan, mengikuti arahan petugas, dan menjaga perilaku adalah bagian dari wisata yang beradab."
  ],
  [
    "Saat mengambil foto di tempat ibadah atau kawasan budaya, sikap terbaik adalah apa?",
    [
      "Meminta izin jika diperlukan dan tidak mengganggu aktivitas orang lain",
      "Memotret wajah semua orang dari dekat tanpa izin",
      "Menggunakan flash di semua area terlarang",
      "Naik ke bangunan yang dilarang"
    ],
    0,
    "etika",
    "Wisata yang baik tetap menghormati privasi, aturan tempat, dan kenyamanan pengunjung lain."
  ],
  [
    "Apa sikap yang tepat saat melihat sesaji atau benda ritual di tempat budaya?",
    [
      "Tidak menyentuh atau memindahkannya sembarangan",
      "Mengambilnya sebagai suvenir",
      "Menendangnya agar jalan lebih luas",
      "Memindahkannya untuk foto"
    ],
    0,
    "etika",
    "Benda ritual atau sesaji memiliki makna bagi masyarakat setempat, sehingga wisatawan sebaiknya tidak menyentuh atau memindahkannya."
  ],
  [
    "Mengapa wisatawan sebaiknya membawa botol minum dan mengurangi sampah plastik?",
    [
      "Agar perjalanan lebih ramah lingkungan",
      "Agar bisa membuang sampah di pantai",
      "Agar barang bawaan makin berat",
      "Agar tidak perlu mengikuti aturan tempat wisata"
    ],
    0,
    "etika",
    "Mengurangi plastik sekali pakai membantu menjaga kebersihan destinasi, terutama area alam dan kawasan ramai wisatawan."
  ],
  [
    "Apa manfaat membeli produk dari pengrajin lokal saat wisata di Jogja?",
    [
      "Mendukung ekonomi masyarakat dan menjaga kerajinan tetap hidup",
      "Membuat destinasi cepat rusak",
      "Mengurangi pendapatan warga",
      "Menghilangkan tradisi lokal"
    ],
    0,
    "etika",
    "Membeli produk lokal membantu ekonomi warga dan ikut menjaga tradisi kerajinan seperti batik, perak, kulit, dan gerabah."
  ],
  [
    "Apa yang membuat Desa Wisata Kasongan dikenal?",
    [
      "Kerajinan gerabah dan tanah liat",
      "Produksi kapal laut",
      "Pusat salju tropis",
      "Tambang minyak"
    ],
    0,
    "destinasi",
    "Kasongan dikenal sebagai sentra gerabah yang cocok dikunjungi wisatawan yang ingin melihat kerajinan lokal."
  ],
  [
    "Desa Wisata Manding terkenal dengan kerajinan apa?",
    [
      "Kulit",
      "Perak",
      "Kaca patri",
      "Kapal kayu"
    ],
    0,
    "destinasi",
    "Manding di Bantul dikenal sebagai sentra kerajinan kulit, mulai dari tas, sepatu, hingga aksesori."
  ],
  [
    "Desa Wisata Krebet dikenal karena produk kreatif apa?",
    [
      "Batik kayu",
      "Patung es",
      "Kain wol salju",
      "Kapal miniatur logam"
    ],
    0,
    "destinasi",
    "Krebet dikenal dengan batik kayu, yaitu produk kerajinan kayu bermotif batik yang unik."
  ],
  [
    "Apa yang bisa dinikmati wisatawan di kawasan Kaliurang?",
    [
      "Udara sejuk lereng Merapi dan wisata alam",
      "Pantai pasir putih",
      "Padang pasir gurun luas",
      "Kawasan industri baja"
    ],
    0,
    "destinasi",
    "Kaliurang menawarkan suasana sejuk lereng Merapi, cocok untuk wisata alam dan keluarga."
  ],
  [
    "Merapi Lava Tour biasanya menawarkan pengalaman apa?",
    [
      "Menjelajah kawasan bekas erupsi Merapi dengan jeep",
      "Menyelam di laut dalam",
      "Naik kapal pesiar",
      "Bermain ski salju"
    ],
    0,
    "destinasi",
    "Lava Tour Merapi memberi pengalaman melihat lanskap bekas erupsi dan cerita tentang kehidupan masyarakat sekitar Merapi."
  ],
  [
    "Apa yang membuat Hutan Pinus Mangunan digemari wisatawan?",
    [
      "Suasana teduh, spot foto, dan udara segar",
      "Kolam air panas belerang di tengah kota",
      "Arena balap internasional",
      "Museum pesawat tempur"
    ],
    0,
    "destinasi",
    "Hutan Pinus Mangunan populer untuk wisata santai, foto, dan menikmati udara yang lebih sejuk."
  ],
  [
    "Puncak Becici sering dipilih untuk menikmati apa?",
    [
      "Pemandangan dari ketinggian dan suasana hutan pinus",
      "Pertunjukan kapal laut",
      "Wisata bawah tanah tambang",
      "Pusat perbelanjaan elektronik"
    ],
    0,
    "destinasi",
    "Puncak Becici menawarkan panorama dari ketinggian dan suasana hutan pinus yang cocok untuk bersantai."
  ],
  [
    "Pantai Timang terkenal dengan pengalaman wisata apa?",
    [
      "Gondola tradisional menuju batu karang dan pemandangan laut",
      "Lift menuju puncak salju",
      "Kebun bunga tulip",
      "Museum dalam ruangan"
    ],
    0,
    "destinasi",
    "Pantai Timang terkenal dengan gondola tradisional dan suasana pantai karang yang menantang."
  ],
  [
    "Pantai Nglambor sering dikenal cocok untuk aktivitas apa?",
    [
      "Snorkeling di area pantai tertentu",
      "Ski es",
      "Melihat kawah gunung api aktif dari dekat",
      "Belanja batik di lorong kota"
    ],
    0,
    "destinasi",
    "Pantai Nglambor populer untuk snorkeling pada kondisi yang aman dan sesuai arahan pengelola."
  ],
  [
    "Apa yang membuat Goa Pindul terkenal?",
    [
      "Cave tubing menyusuri sungai bawah tanah",
      "Kereta gantung salju",
      "Pertunjukan wayang setiap jam",
      "Pusat kuliner gudeg"
    ],
    0,
    "destinasi",
    "Goa Pindul dikenal dengan cave tubing, yaitu menyusuri aliran air dalam gua menggunakan ban pelampung."
  ],
  [
    "Air Terjun Sri Gethuk dikenal dengan suasana apa?",
    [
      "Air terjun dan aliran sungai di kawasan Gunungkidul",
      "Pantai pasir hitam",
      "Benteng kolonial",
      "Pusat belanja malam"
    ],
    0,
    "destinasi",
    "Sri Gethuk menawarkan suasana alam berupa air terjun dan aliran sungai yang menarik untuk wisata santai."
  ],
  [
    "Apa yang membuat HeHa Sky View populer bagi wisatawan?",
    [
      "Spot foto, kuliner, dan pemandangan kota dari ketinggian",
      "Koleksi keris kuno",
      "Wisata sejarah Mataram Islam",
      "Pertunjukan wayang kulit klasik"
    ],
    0,
    "destinasi",
    "HeHa Sky View populer karena menggabungkan pemandangan, spot foto, dan pilihan kuliner."
  ],
  [
    "Prawirotaman dikenal sebagai kawasan yang ramah wisatawan karena apa?",
    [
      "Banyak kafe, penginapan, tempat makan, dan suasana santai",
      "Lokasi tambang batu bara",
      "Kawasan tertutup militer",
      "Hutan lindung tanpa akses umum"
    ],
    0,
    "destinasi",
    "Prawirotaman adalah kawasan yang sering dipilih wisatawan karena suasana santai, kuliner, kafe, dan penginapan."
  ],
  [
    "Apa pesan utama dari filosofi hamemayu hayuning bawana?",
    [
      "Manusia ikut menjaga keindahan dan keselamatan dunia",
      "Manusia bebas merusak alam",
      "Keindahan hanya untuk bangunan mewah",
      "Tradisi tidak perlu dijaga"
    ],
    0,
    "filosofi",
    "Hamemayu hayuning bawana sering dimaknai sebagai ajakan menjaga harmoni dan keindahan dunia."
  ],
  [
    "Apa yang dimaksud gotong royong dalam kehidupan masyarakat Jawa?",
    [
      "Bekerja bersama untuk kepentingan bersama",
      "Bersaing tanpa peduli tetangga",
      "Menyendiri dari masyarakat",
      "Menolak membantu orang lain"
    ],
    0,
    "budaya",
    "Gotong royong mencerminkan kebersamaan dan saling membantu dalam kehidupan sosial."
  ],
  [
    "Gamelan dalam budaya Jawa biasanya berfungsi sebagai apa?",
    [
      "Ansambel musik tradisional untuk upacara, tari, pertunjukan, dan pendidikan budaya",
      "Alat transportasi tradisional",
      "Jenis makanan manis",
      "Nama pasar malam"
    ],
    0,
    "budaya",
    "Gamelan adalah ansambel musik tradisional yang lekat dengan tari, wayang, upacara, dan pertunjukan budaya Jawa."
  ],
  [
    "Wayang kulit sering digunakan untuk menyampaikan apa selain hiburan?",
    [
      "Nilai moral, filosofi, dan cerita kehidupan",
      "Jadwal penerbangan",
      "Harga bahan bangunan",
      "Aturan parkir modern"
    ],
    0,
    "budaya",
    "Wayang kulit tidak hanya menghibur, tetapi juga menyampaikan nilai moral, filosofi, dan refleksi kehidupan."
  ],
  [
    "Apa peran dalang dalam pertunjukan wayang kulit?",
    [
      "Menghidupkan tokoh, mengatur cerita, suara, dan alur pertunjukan",
      "Menjual tiket pesawat",
      "Mengemudikan bus wisata",
      "Memasak hidangan utama"
    ],
    0,
    "budaya",
    "Dalang adalah pusat pertunjukan wayang: menggerakkan tokoh, mengisi suara, mengatur cerita, dan menyampaikan pesan."
  ],
  [
    "Apa yang dimaksud dengan Sekaten di Yogyakarta?",
    [
      "Tradisi budaya dan keagamaan yang berkaitan dengan peringatan Maulid Nabi",
      "Festival salju tahunan",
      "Lomba kapal pesiar",
      "Upacara panen teh"
    ],
    0,
    "budaya",
    "Sekaten merupakan tradisi yang berkaitan dengan peringatan Maulid Nabi dan menjadi bagian penting dari budaya Yogyakarta."
  ],
  [
    "Grebeg di Yogyakarta biasanya dikenal dengan simbol gunungan. Apa maknanya bagi masyarakat?",
    [
      "Ungkapan syukur dan sedekah raja kepada rakyat",
      "Kompetisi memasak modern",
      "Lomba panjat tebing",
      "Pameran mobil sport"
    ],
    0,
    "budaya",
    "Grebeg dengan gunungan melambangkan rasa syukur dan sedekah dari Keraton kepada masyarakat."
  ],
  [
    "Apa nama pasar tradisional besar dekat Malioboro yang sering dikunjungi wisatawan?",
    [
      "Pasar Beringharjo",
      "Pasar Terapung Lok Baintan",
      "Pasar Sukawati",
      "Pasar Atas Bukittinggi"
    ],
    0,
    "destinasi",
    "Pasar Beringharjo adalah pasar tradisional ikonik dekat Malioboro yang terkenal dengan batik, jajanan, dan suasana lokal."
  ],
  [
    "Apa yang paling tepat dibeli di Pasar Beringharjo sebagai oleh-oleh khas?",
    [
      "Batik, jajanan, dan kerajinan",
      "Perahu nelayan",
      "Salju kemasan",
      "Peralatan tambang"
    ],
    0,
    "kuliner",
    "Beringharjo cocok untuk mencari batik, jajanan pasar, rempah, dan kerajinan khas Jogja."
  ],
  [
    "Apa yang membuat batik motif parang sering dianggap berwibawa?",
    [
      "Motifnya memiliki makna keteguhan, kekuatan, dan kesinambungan",
      "Karena dibuat dari logam berat",
      "Karena hanya dipakai saat berenang",
      "Karena tidak punya pola berulang"
    ],
    0,
    "filosofi",
    "Motif parang sering dikaitkan dengan keteguhan dan kesinambungan, sehingga memiliki nilai simbolik kuat dalam budaya Jawa."
  ],
  [
    "Mengapa wisatawan perlu menghargai aturan berpakaian di tempat budaya?",
    [
      "Karena pakaian sopan menunjukkan rasa hormat pada ruang dan tradisi setempat",
      "Agar bisa masuk tanpa membeli tiket",
      "Agar bisa menyentuh koleksi museum",
      "Agar bisa mengambil benda ritual"
    ],
    0,
    "etika",
    "Berpakaian sopan adalah bentuk penghormatan terhadap tempat budaya, masyarakat lokal, dan pengunjung lain."
  ],
  [
    "Apa sikap yang baik saat menawar di pasar tradisional?",
    [
      "Menawar dengan sopan dan tetap menghargai penjual",
      "Membentak penjual agar harga turun",
      "Mengambil barang sebelum membayar",
      "Mengejek produk lokal"
    ],
    0,
    "etika",
    "Menawar boleh dilakukan di beberapa pasar, tetapi tetap perlu sopan dan menghargai kerja penjual."
  ],
  [
    "Mengapa wisatawan sebaiknya datang pagi atau sore ke banyak destinasi outdoor di Jogja?",
    [
      "Cuaca lebih nyaman dan cahaya lebih bagus untuk menikmati tempat",
      "Karena semua tempat hanya buka tengah malam",
      "Karena tidak boleh datang saat terang",
      "Karena transportasi selalu berhenti siang hari"
    ],
    0,
    "fakta",
    "Pagi dan sore sering lebih nyaman untuk wisata luar ruang karena suhu tidak terlalu panas dan cahaya lebih enak untuk foto."
  ],
  [
    "Apa alasan wisata kuliner Jogja sering terasa ramah bagi backpacker dan mahasiswa?",
    [
      "Banyak pilihan makanan sederhana dengan harga terjangkau",
      "Semua restoran wajib sangat mahal",
      "Tidak ada jajanan malam",
      "Hanya tersedia makanan hotel"
    ],
    0,
    "kuliner",
    "Jogja dikenal memiliki banyak pilihan kuliner terjangkau, dari angkringan sampai warung lokal."
  ],
  [
    "Apa yang membuat Alun-Alun Kidul terkenal pada malam hari?",
    [
      "Suasana santai, odong-odong lampu, dan aktivitas keluarga",
      "Pusat ski es",
      "Museum bawah laut",
      "Area tambang emas"
    ],
    0,
    "destinasi",
    "Alun-Alun Kidul populer untuk suasana malam yang santai, kuliner ringan, dan kendaraan hias lampu."
  ],
  [
    "Tradisi berjalan melewati dua beringin di Alun-Alun Kidul dikenal dengan nama apa?",
    [
      "Masangin",
      "Sekaten",
      "Labuhan",
      "Tedhak Siten"
    ],
    0,
    "budaya",
    "Masangin adalah tradisi permainan berjalan melewati dua beringin dengan mata tertutup di Alun-Alun Kidul."
  ],
  [
    "Apa yang membuat Jalan Malioboro cocok untuk wisata keluarga?",
    [
      "Akses mudah, banyak pilihan belanja, kuliner, dan area jalan kaki",
      "Medan pendakian ekstrem",
      "Kawasan tertutup tanpa fasilitas",
      "Hanya bisa dikunjungi dengan kapal"
    ],
    0,
    "destinasi",
    "Malioboro mudah dijangkau dan menyediakan banyak pilihan aktivitas ringan untuk berbagai usia."
  ],
  [
    "Jika wisatawan ingin belajar tentang keris, wayang, dan batik, tempat yang cocok adalah...",
    [
      "Museum Sonobudoyo",
      "Pantai Timang",
      "Gumuk Pasir",
      "Bandara YIA"
    ],
    0,
    "destinasi",
    "Museum Sonobudoyo menyimpan banyak koleksi budaya Jawa, termasuk keris, wayang, batik, dan naskah."
  ],
  [
    "Jika wisatawan mencari suasana seni lukis Affandi, destinasi yang tepat adalah...",
    [
      "Museum Affandi",
      "Pasar Beringharjo",
      "Pantai Parangtritis",
      "Tugu Jogja"
    ],
    0,
    "destinasi",
    "Museum Affandi menampilkan karya dan suasana kediaman Affandi, salah satu maestro seni lukis Indonesia."
  ],
  [
    "Apa yang membuat wisata desa di Jogja menarik?",
    [
      "Pengalaman langsung dengan kehidupan lokal, kerajinan, alam, dan tradisi",
      "Semua aktivitas dilakukan di mal tertutup",
      "Hanya berisi gedung perkantoran",
      "Tidak ada interaksi dengan warga"
    ],
    0,
    "destinasi",
    "Wisata desa memberi pengalaman lebih dekat dengan kehidupan lokal, kerajinan, tradisi, dan keramahan warga."
  ],
  [
    "Apa yang sebaiknya dilakukan sebelum membuka rute Google Maps menuju destinasi?",
    [
      "Cek lokasi, jam buka, dan kondisi perjalanan terbaru",
      "Langsung berangkat tanpa melihat jarak",
      "Mengabaikan cuaca",
      "Tidak perlu cek aturan tempat"
    ],
    0,
    "etika",
    "Mengecek lokasi, jam buka, cuaca, dan rute membantu perjalanan lebih aman dan nyaman."
  ],
  [
    "Mengapa tidak semua tempat budaya boleh difoto sembarangan?",
    [
      "Beberapa area memiliki aturan, nilai sakral, atau koleksi sensitif",
      "Karena kamera selalu dilarang di seluruh Jogja",
      "Karena semua tempat gelap",
      "Karena foto hanya boleh di pantai"
    ],
    0,
    "etika",
    "Beberapa area budaya memiliki aturan tertentu, sehingga wisatawan perlu membaca petunjuk dan menghormati larangan foto."
  ],
  [
    "Apa yang membuat Yogyakarta sering disebut kota pelajar?",
    [
      "Banyak lembaga pendidikan dan mahasiswa dari berbagai daerah",
      "Karena hanya memiliki sekolah dasar",
      "Karena tidak ada universitas",
      "Karena semua warganya wajib menjadi guru"
    ],
    0,
    "fakta",
    "Yogyakarta dikenal sebagai kota pelajar karena banyaknya kampus dan pelajar/mahasiswa dari berbagai daerah."
  ],
  [
    "Mengapa Jogja sering terasa nyaman untuk jalan kaki di area tertentu seperti Malioboro?",
    [
      "Banyak ruang publik, toko, kuliner, dan titik menarik dalam jarak dekat",
      "Semua destinasi berada di bawah tanah",
      "Tidak ada trotoar sama sekali",
      "Hanya kendaraan pribadi yang boleh masuk"
    ],
    0,
    "fakta",
    "Beberapa kawasan pusat kota Jogja memiliki banyak titik menarik yang berdekatan, sehingga cocok dinikmati dengan berjalan santai."
  ],
  [
    "Apa yang dimaksud wisata heritage?",
    [
      "Wisata yang menonjolkan warisan sejarah, budaya, dan bangunan bersejarah",
      "Wisata khusus wahana air modern",
      "Wisata belanja elektronik",
      "Wisata olahraga ekstrem saja"
    ],
    0,
    "fakta",
    "Wisata heritage mengajak pengunjung mengenal warisan sejarah, budaya, dan bangunan yang memiliki nilai penting."
  ],
  [
    "Mengapa destinasi kuliner tradisional penting bagi pengalaman wisata?",
    [
      "Karena makanan menyimpan cerita, kebiasaan, dan identitas lokal",
      "Karena makanan tidak ada hubungannya dengan budaya",
      "Karena wisata hanya boleh melihat bangunan",
      "Karena kuliner selalu harus mahal"
    ],
    0,
    "kuliner",
    "Kuliner tradisional adalah bagian dari budaya. Dari rasa, cara penyajian, hingga tempat makan, semuanya menyimpan cerita lokal."
  ],
  [
    "Apa yang bisa dipelajari dari mengunjungi Keraton Yogyakarta?",
    [
      "Tata ruang, sejarah, seni, dan nilai budaya Jawa",
      "Cara membuat pesawat jet",
      "Teknik menambang batu bara",
      "Sejarah negara Eropa modern saja"
    ],
    0,
    "budaya",
    "Keraton memperlihatkan hubungan antara tata ruang, tradisi, seni, dan nilai budaya Jawa dalam kehidupan Yogyakarta."
  ],
  [
    "Apa alasan wisatawan perlu menjaga volume suara di museum atau tempat budaya?",
    [
      "Agar tidak mengganggu suasana, pengunjung lain, dan aktivitas budaya",
      "Agar bisa masuk gratis",
      "Agar koleksi museum bergerak",
      "Agar petugas tidak terlihat"
    ],
    0,
    "etika",
    "Menjaga suara adalah bagian dari etika berkunjung, terutama di tempat edukatif, sakral, atau bersejarah."
  ],
  [
    "Apa yang dimaksud oleh-oleh yang bertanggung jawab?",
    [
      "Membeli produk legal, lokal, dan tidak merusak alam atau budaya",
      "Mengambil batu dari situs bersejarah",
      "Membawa pulang benda ritual tanpa izin",
      "Membeli satwa liar dilindungi"
    ],
    0,
    "etika",
    "Oleh-oleh yang baik mendukung ekonomi lokal tanpa merusak alam, situs sejarah, atau nilai budaya."
  ],
  [
    "Apa yang membuat kuliner oseng mercon terkenal di Jogja?",
    [
      "Rasa pedas kuat yang menantang",
      "Rasa manis seperti permen",
      "Disajikan sebagai es serut",
      "Berbahan utama buah salju"
    ],
    0,
    "kuliner",
    "Oseng mercon dikenal karena rasa pedasnya yang kuat, cocok untuk wisatawan pencinta makanan pedas."
  ],
  [
    "Apa yang membuat geplak dikenal sebagai jajanan khas Bantul?",
    [
      "Rasa manis dari kelapa parut dan gula",
      "Rasa asin dari ikan fermentasi",
      "Minuman rempah panas",
      "Sup daging berkuah hitam"
    ],
    0,
    "kuliner",
    "Geplak adalah jajanan manis berbahan kelapa parut dan gula yang lekat dengan Bantul."
  ],
  [
    "Apa yang paling menggambarkan suasana belanja di Beringharjo?",
    [
      "Ramai, tradisional, banyak pilihan batik dan jajanan",
      "Sepi seperti hutan pinus",
      "Hanya menjual perlengkapan kapal",
      "Tidak ada interaksi tawar-menawar"
    ],
    0,
    "destinasi",
    "Beringharjo menawarkan suasana pasar tradisional yang hidup, dengan batik, jajanan, dan interaksi lokal."
  ],
  [
    "Jika ingin menikmati sisi klasik kota Jogja, kombinasi rute yang cocok adalah...",
    [
      "Keraton, Taman Sari, Vredeburg, Malioboro",
      "Bandara, jalan tol, pabrik, gudang",
      "Pantai, pelabuhan besar, kapal pesiar, mercusuar",
      "Kebun teh, salju, lift ski, dan danau es"
    ],
    0,
    "destinasi",
    "Keraton, Taman Sari, Vredeburg, dan Malioboro berada dalam rute kota yang kuat secara sejarah dan suasana klasik Jogja."
  ],
  [
    "Apa yang sebaiknya dilakukan wisatawan saat berkunjung ke pantai selatan Jogja?",
    [
      "Mematuhi peringatan ombak dan arahan petugas",
      "Berenang sejauh mungkin tanpa melihat kondisi",
      "Mengabaikan papan larangan",
      "Berdiri terlalu dekat ombak besar untuk foto"
    ],
    0,
    "etika",
    "Pantai selatan memiliki ombak kuat di beberapa titik, sehingga keselamatan dan arahan petugas harus diutamakan."
  ],
  [
    "Mengapa wisata alam perlu dijaga kebersihannya?",
    [
      "Agar tetap nyaman, aman, dan bisa dinikmati pengunjung berikutnya",
      "Agar sampah menjadi hiasan",
      "Agar satwa liar mendekat ke plastik",
      "Agar destinasi cepat ditutup"
    ],
    0,
    "etika",
    "Menjaga kebersihan berarti ikut merawat destinasi agar tetap indah dan berkelanjutan."
  ],
  [
    "Apa keunikan Titik Nol Kilometer saat malam hari?",
    [
      "Suasana kota, lampu, bangunan tua, dan aktivitas ruang publik",
      "Pertunjukan salju buatan",
      "Pusat memancing laut",
      "Ladang teh bertingkat"
    ],
    0,
    "destinasi",
    "Titik Nol Kilometer sering ramai pada malam hari karena suasana kota, bangunan bersejarah, dan aktivitas publik."
  ],
  [
    "Apa nama kawasan yang dikenal sebagai pusat kerajinan perak di Jogja?",
    [
      "Kotagede",
      "Kaliurang",
      "Parangtritis",
      "Prawirotaman"
    ],
    0,
    "destinasi",
    "Kotagede terkenal sebagai kawasan bersejarah sekaligus sentra kerajinan perak."
  ],
  [
    "Apa yang sebaiknya dilakukan jika wisatawan tersesat di kawasan wisata?",
    [
      "Bertanya kepada petugas atau warga dengan sopan dan membuka peta",
      "Panik lalu berlari tanpa arah",
      "Masuk ke area terlarang",
      "Mematikan semua komunikasi"
    ],
    0,
    "etika",
    "Bertanya dengan sopan dan menggunakan peta adalah langkah aman saat tersesat."
  ],
  [
    "Apa manfaat menggunakan fitur rekomendasi terdekat di aplikasi wisata?",
    [
      "Membantu memilih destinasi yang jaraknya lebih dekat dari posisi pengguna",
      "Membuat lokasi pengguna hilang",
      "Menonaktifkan peta",
      "Menghapus semua destinasi"
    ],
    0,
    "fakta",
    "Rekomendasi terdekat memudahkan wisatawan memilih tempat yang realistis dikunjungi berdasarkan posisi saat itu."
  ],
  [
    "Apa yang membuat destinasi ikonik berbeda dari tempat biasa?",
    [
      "Memiliki daya tarik kuat, cerita, dan dikenal luas oleh wisatawan",
      "Selalu berada di bawah tanah",
      "Tidak boleh dikunjungi",
      "Tidak memiliki informasi lokasi"
    ],
    0,
    "fakta",
    "Destinasi ikonik biasanya dikenal luas karena cerita, nilai budaya, keunikan visual, atau pengalaman yang kuat."
  ],
  [
    "Apa yang sebaiknya ditanyakan kepada Guide AI JogjaSplorasi jika ingin perjalanan santai?",
    [
      "Rekomendasi tempat dekat, durasi kunjungan, dan suasana destinasi",
      "Cara merusak fasilitas umum",
      "Tempat mengambil benda museum",
      "Cara menghindari aturan wisata"
    ],
    0,
    "fakta",
    "Guide AI paling berguna saat diberi konteks seperti lokasi, waktu, minat, dan gaya perjalanan yang diinginkan."
  ],
  [
    "Mengapa cuaca perlu dipertimbangkan saat memilih destinasi Jogja?",
    [
      "Karena wisata outdoor lebih nyaman jika disesuaikan dengan panas atau hujan",
      "Karena semua destinasi tutup saat pagi",
      "Karena cuaca tidak memengaruhi perjalanan sama sekali",
      "Karena peta hanya bekerja saat hujan"
    ],
    0,
    "fakta",
    "Cuaca memengaruhi kenyamanan, keselamatan, dan pilihan destinasi, terutama untuk pantai, hutan, atau spot foto outdoor."
  ],
  [
    "Apa yang membuat wisata budaya cocok untuk keluarga?",
    [
      "Bisa menjadi pengalaman jalan-jalan sekaligus belajar sejarah dan nilai lokal",
      "Karena tidak boleh membawa anak",
      "Karena semua tempat budaya tertutup untuk umum",
      "Karena hanya tersedia tengah malam"
    ],
    0,
    "budaya",
    "Wisata budaya bisa dinikmati lintas usia karena memberi pengalaman visual, cerita, dan pembelajaran yang menyenangkan."
  ],
  [
    "Apa alasan destinasi seperti Keraton dan Taman Sari cocok dipasangkan dalam satu rute?",
    [
      "Lokasinya relatif berdekatan dan sama-sama kuat secara sejarah",
      "Keduanya berada di luar negeri",
      "Keduanya hanya bisa dicapai dengan kapal",
      "Keduanya merupakan gunung aktif"
    ],
    0,
    "destinasi",
    "Keraton dan Taman Sari berada di kawasan yang berdekatan, sehingga cocok menjadi rute wisata sejarah kota."
  ],
  [
    "Apa yang membuat kawasan Imogiri menarik bagi wisatawan budaya dan kuliner?",
    [
      "Ada cerita sejarah, makam raja, dan kuliner/minuman tradisional seperti wedang uwuh",
      "Ada salju abadi",
      "Pusat belanja elektronik terbesar",
      "Arena balap mobil internasional"
    ],
    0,
    "destinasi",
    "Imogiri memiliki nilai sejarah dan budaya, serta dikenal dengan kuliner dan minuman tradisional seperti wedang uwuh."
  ],
  [
    "Apa arti pengalaman 'slow travel' yang cocok diterapkan di Jogja?",
    [
      "Menikmati tempat dengan pelan, menghargai cerita, warga, dan suasana lokal",
      "Berlari secepat mungkin melewati semua destinasi",
      "Hanya mengambil foto tanpa membaca cerita",
      "Mengabaikan budaya setempat"
    ],
    0,
    "fakta",
    "Slow travel mengajak wisatawan menikmati perjalanan dengan lebih sadar, tidak terburu-buru, dan lebih menghargai tempat."
  ],
  [
    "Mengapa wisatawan perlu membaca deskripsi destinasi sebelum berangkat?",
    [
      "Agar tahu cerita, aturan, kategori, dan perkiraan aktivitas di tempat tersebut",
      "Agar tidak perlu membawa peta",
      "Agar bisa masuk area terlarang",
      "Agar destinasi berubah lokasi"
    ],
    0,
    "fakta",
    "Membaca deskripsi membantu wisatawan memahami daya tarik, aturan, dan kecocokan destinasi dengan kebutuhan perjalanan."
  ],
  [
    "Apa yang membuat Yogyakarta punya daya tarik kuat bagi wisatawan budaya?",
    [
      "Perpaduan Keraton, tradisi, seni, kuliner, sejarah, dan keramahan warga",
      "Karena tidak memiliki tempat sejarah",
      "Karena semua destinasi hanya berupa mal",
      "Karena budaya lokal tidak terlihat"
    ],
    0,
    "budaya",
    "Yogyakarta kuat sebagai destinasi budaya karena tradisi, seni, sejarah, kuliner, dan kehidupan lokalnya masih mudah ditemui."
  ],
  [
    "Apa pengalaman yang bisa dicari wisatawan di kampung wisata?",
    [
      "Belajar kerajinan, mengenal warga, dan merasakan suasana lokal",
      "Mencari salju buatan",
      "Melihat pabrik tertutup",
      "Menyelam di laut dalam"
    ],
    0,
    "destinasi",
    "Kampung wisata menawarkan pengalaman lebih personal melalui aktivitas warga, kerajinan, kuliner, dan budaya lokal."
  ],
  [
    "Apa yang sebaiknya dilakukan setelah menikmati makanan di area wisata?",
    [
      "Membuang sampah pada tempatnya dan menjaga area tetap bersih",
      "Meninggalkan bungkus makanan di meja umum",
      "Membuang plastik ke sungai",
      "Menyelipkan sampah di pot tanaman"
    ],
    0,
    "etika",
    "Kebersihan area wisata adalah tanggung jawab bersama agar tempat tetap nyaman bagi semua pengunjung."
  ],
  [
    "Apa yang dimaksud destinasi ramah lansia dalam konteks aplikasi wisata?",
    [
      "Informasi jelas, akses mudah, teks terbaca, dan alur sederhana",
      "Semua tombol dibuat kecil",
      "Informasi disembunyikan",
      "Navigasi dibuat membingungkan"
    ],
    0,
    "fakta",
    "Destinasi atau aplikasi ramah lansia perlu informasi jelas, tombol mudah dipahami, teks terbaca, dan alur yang tidak rumit."
  ],
  [
    "Mengapa tombol 'Buka Maps' penting untuk aplikasi wisata?",
    [
      "Agar pengguna bisa langsung melihat rute menuju destinasi",
      "Agar aplikasi menutup sendiri",
      "Agar data destinasi hilang",
      "Agar quiz otomatis selesai"
    ],
    0,
    "fakta",
    "Tombol Maps membantu wisatawan berpindah dari rekomendasi ke aksi nyata: melihat rute dan menuju lokasi."
  ],
  [
    "Apa yang membuat wisata sejarah terasa lebih menarik untuk anak muda?",
    [
      "Cerita disampaikan singkat, visual menarik, dan dikaitkan dengan pengalaman saat ini",
      "Semua teks dibuat sangat panjang tanpa gambar",
      "Tidak ada cerita sama sekali",
      "Tempat dikunci dari pengunjung"
    ],
    0,
    "fakta",
    "Sejarah lebih mudah dinikmati jika disajikan dengan cerita yang hidup, visual menarik, dan relevan dengan pengalaman pengunjung."
  ]
];
async function main(){
  const adminPass = await bcrypt.hash('Admin12345',12);
  await prisma.user.upsert({where:{email:'admin@jogjasplorasi.local'},update:{role:'ADMIN'},create:{email:'admin@jogjasplorasi.local',passwordHash:adminPass,role:'ADMIN',profile:{create:{fullName:'JogjaSplorasi Admin'}},preferences:{create:{}}}});
  for (const d of destinations){
    const [name,type,category,lat,lng,description,address,tags,culturalValue]=d;
    const slug = slugify(name,{lower:true,strict:true});
    await prisma.destination.upsert({where:{slug},update:{name,type,category,latitude:lat,longitude:lng,description,address,tags:String(tags).split(','),culturalValue,rating:4.3,isFeatured:culturalValue>=4,openingHours:'Perlu verifikasi berkala di sumber resmi',ticketPrice:'Perlu verifikasi berkala',bestTimeToVisit:'Pagi atau sore',recommendedDuration:'1-3 jam',isActive:true,isVerified:false},create:{name,slug,type,category,latitude:lat,longitude:lng,description,address,tags:String(tags).split(','),culturalValue,rating:4.3,isFeatured:culturalValue>=4,openingHours:'Perlu verifikasi berkala di sumber resmi',ticketPrice:'Perlu verifikasi berkala',bestTimeToVisit:'Pagi atau sore',recommendedDuration:'1-3 jam',isActive:true,isVerified:false}});
  }
  await prisma.quizAttemptAnswer.deleteMany();
  await prisma.quizOption.deleteMany();
  await prisma.quizQuestion.deleteMany();
  for (const q of quiz){
    const [questionText,options,correctIndex,category,explanation]=q;
    await prisma.quizQuestion.create({data:{questionText,category,explanation,options:{create:options.map((optionText,i)=>({optionText,isCorrect:i===correctIndex}))}}});
  }
  console.log(`Seed completed: ${destinations.length} destinations and ${quiz.length} quiz questions. Admin: admin@jogjasplorasi.local / Admin12345`);
}
main().catch((e)=>{ console.error(e); process.exit(1); }).finally(()=>prisma.$disconnect());
