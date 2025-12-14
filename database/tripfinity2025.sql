-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: tripfinity
-- ------------------------------------------------------
-- Server version	8.0.43

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admin_actions`
--

DROP TABLE IF EXISTS `admin_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_actions` (
  `action_id` int NOT NULL AUTO_INCREMENT,
  `admin_id` int NOT NULL,
  `action_type` varchar(100) NOT NULL,
  `target_type` enum('user','provider','hotel','restaurant','attraction','tour','blog','booking','review','other') NOT NULL,
  `target_id` int DEFAULT NULL,
  `admin_action_description` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`action_id`),
  KEY `fk_admin_actions_admin` (`admin_id`),
  CONSTRAINT `fk_admin_actions_admin` FOREIGN KEY (`admin_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_actions`
--

LOCK TABLES `admin_actions` WRITE;
/*!40000 ALTER TABLE `admin_actions` DISABLE KEYS */;
/*!40000 ALTER TABLE `admin_actions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `areas`
--

DROP TABLE IF EXISTS `areas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `areas` (
  `area_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `area_type` enum('city','district','province') COLLATE utf8mb4_unicode_ci NOT NULL,
  `short_description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cover_image_url` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`area_id`),
  UNIQUE KEY `slug` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `areas`
--

LOCK TABLES `areas` WRITE;
/*!40000 ALTER TABLE `areas` DISABLE KEYS */;
INSERT INTO `areas` VALUES (1,'An Giang','an-giang','province','Tỉnh ven sông, có nhiều di tích văn hoá và lễ hội.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(2,'Bà Rịa - Vũng Tàu','ba-ria-vung-tau','province','Tỉnh biển với nhiều bãi tắm và khu du lịch nghỉ dưỡng.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(3,'Bắc Kạn','bac-kan','province','Tỉnh miền núi phía Bắc, nhiều cảnh quan thiên nhiên.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(4,'Bắc Giang','bac-giang','province','Tỉnh phía Bắc với các khu công nghiệp và danh lam.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(5,'Bạc Liêu','bac-lieu','province','Tỉnh đồng bằng sông Cửu Long, nổi tiếng văn hoá đờn ca tài tử.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(6,'Bắc Ninh','bac-ninh','province','Vùng đất Kinh Bắc với nhiều di sản văn hoá truyền thống.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(7,'Bến Tre','ben-tre','province','Tỉnh sông nước miền Tây, nổi tiếng dừa và du lịch miệt vườn.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(8,'Bình Định','binh-dinh','province','Tỉnh miền Trung có nhiều di tích võ cổ truyền và bãi biển.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(9,'Bình Dương','binh-duong','province','Trung tâm công nghiệp và đô thị đang phát triển nhanh.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(10,'Bình Phước','binh-phuoc','province','Tỉnh Đông Nam Bộ, nhiều vùng trồng cây công nghiệp.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(11,'Bình Thuận','binh-thuan','province','Tỉnh ven biển, nổi tiếng Mũi Né và cảnh quan ven biển.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(12,'Cà Mau','ca-mau','province','Mũi Cà Mau - điểm cực Nam của đất nước, nhiều hệ sinh thái ngập mặn.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(13,'Cần Thơ','can-tho','province','Trung tâm đồng bằng sông Cửu Long, nổi tiếng với chợ nổi.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(14,'Cao Bằng','cao-bang','province','Vùng núi phía Bắc với thác Bản Giốc và nhiều di tích lịch sử.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(15,'Đà Nẵng','da-nang','province','Thành phố biển miền Trung, gần nhiều điểm du lịch nổi tiếng.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(16,'Đắk Lắk','dak-lak','province','Tỉnh Tây Nguyên, nổi tiếng cà phê và văn hoá dân tộc.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(17,'Đắk Nông','dak-nong','province','Tỉnh Tây Nguyên với nhiều cảnh quan thiên nhiên hoang sơ.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(18,'Điện Biên','dien-bien','province','Tỉnh miền núi, nổi tiếng lịch sử Điện Biên Phủ.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(19,'Đồng Nai','dong-nai','province','Tỉnh có nhiều khu công nghiệp và khu du lịch sinh thái.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(20,'Đồng Tháp','dong-thap','province','Vùng đất sen hồng, nổi tiếng phong cảnh miền Tây.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(21,'Gia Lai','gia-lai','province','Tỉnh Tây Nguyên với cao nguyên và văn hoá bản địa.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(22,'Hà Giang','ha-giang','province','Vùng cao nguyên đá nổi tiếng với đèo Mã Pì Lèng và hoa tam giác mạch.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(23,'Hà Nam','ha-nam','province','Tỉnh đồng bằng Bắc Bộ, gần Hà Nội với nhiều di tích lịch sử.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(24,'Hà Nội','ha-noi','province','Thủ đô của Việt Nam với nhiều di tích lịch sử và văn hoá.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(25,'Hà Tĩnh','ha-tinh','province','Tỉnh miền Trung với bờ biển dài và di tích lịch sử.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(26,'Hải Dương','hai-duong','province','Vùng đồng bằng Bắc Bộ, nổi tiếng nông sản và chợ hoa.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(27,'Hải Phòng','hai-phong','province','Thành phố cảng miền Bắc, nổi tiếng với ẩm thực hải sản.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(28,'Hậu Giang','hau-giang','province','Tỉnh miền Tây với nhiều kênh rạch và nông nghiệp.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(29,'Hòa Bình','hoa-binh','province','Tỉnh miền núi phía Bắc, nhiều hồ và cảnh quan thiên nhiên.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(30,'Hưng Yên','hung-yen','province','Vùng đồng bằng Bắc Bộ, nổi tiếng vải thiều và làng nghề.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(31,'Khánh Hòa','khanh-hoa','province','Tỉnh biển với Nha Trang — trung tâm du lịch biển nổi tiếng.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(32,'Kiên Giang','kien-giang','province','Tỉnh ven biển và đảo, bao gồm Phú Quốc và nhiều bãi biển đẹp.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(33,'Kon Tum','kon-tum','province','Tỉnh Tây Nguyên, nhiều văn hoá dân tộc và cảnh quan núi rừng.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(34,'Lai Châu','lai-chau','province','Tỉnh miền núi phía Bắc, cảnh quan hoang sơ và đèo dốc.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(35,'Lâm Đồng','lam-dong','province','Tỉnh cao nguyên Lâm Viên, nổi tiếng Đà Lạt và cảnh quan ôn đới.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(36,'Lạng Sơn','lang-son','province','Tỉnh biên giới phía Bắc, nhiều danh thắng và cửa khẩu thương mại.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(37,'Lào Cai','lao-cai','province','Tỉnh miền núi, có Sa Pa và cảnh quan núi non hùng vĩ.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(38,'Long An','long-an','province','Tỉnh đồng bằng phát triển nông nghiệp và khu công nghiệp.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(39,'Nam Định','nam-dinh','province','Vùng ven biển Bắc Bộ có nhiều di tích lịch sử và lễ hội.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(40,'Nghệ An','nghe-an','province','Tỉnh rộng lớn miền Trung, quê hương nhiều danh nhân lịch sử.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(41,'Ninh Bình','ninh-binh','province','Tỉnh có quần thể Tràng An, Bái Đính và nhiều cảnh quan kì vĩ.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(42,'Ninh Thuận','ninh-thuan','province','Tỉnh ven biển miền Trung với nhiều vùng nắng gió và di sản Cham.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(43,'Phú Thọ','phu-tho','province','Đất Tổ Hùng Vương, có nhiều di tích lịch sử và lễ hội dân gian.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(44,'Phú Yên','phu-yen','province','Tỉnh ven biển miền Trung, nổi tiếng với Gành Đá Dĩa và bãi biển.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(45,'Quảng Bình','quang-binh','province','Nổi tiếng hang Sơn Đoòng và nhiều hang động lớn.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(46,'Quảng Nam','quang-nam','province','Có phố cổ Hội An và nhiều di tích văn hoá, bãi biển đẹp.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(47,'Quảng Ngãi','quang-ngai','province','Tỉnh miền Trung với nhiều bãi biển và lịch sử hào hùng.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(48,'Quảng Ninh','quang-ninh','province','Nổi tiếng Vịnh Hạ Long — di sản thiên nhiên thế giới.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(49,'Quảng Trị','quang-tri','province','Tỉnh miền Trung giàu lịch sử với nhiều di tích chiến tranh.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(50,'Sóc Trăng','soc-trang','province','Tỉnh miền Tây có nền văn hoá Khmer và lễ hội đặc sắc.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(51,'Sơn La','son-la','province','Tỉnh miền núi phía Bắc, nổi tiếng chè và nông sản vùng cao.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(52,'Tây Ninh','tay-ninh','province','Tỉnh gần TP.HCM, có núi Bà Đen và điểm hành hương Cao Đài.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(53,'Thái Bình','thai-binh','province','Vùng đồng bằng Bắc Bộ, nổi tiếng làng nghề và nông sản.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(54,'Thái Nguyên','thai-nguyen','province','Trung tâm vùng trung du miền núi phía Bắc, nổi tiếng chè.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(55,'Thanh Hóa','thanh-hoa','province','Tỉnh lớn miền Bắc có bờ biển dài và nhiều thắng cảnh.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(56,'Thừa Thiên - Huế','thua-thien-hue','province','Cố đô Huế với kiến trúc cung đình và di sản văn hoá phong phú.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(57,'Tiền Giang','tien-giang','province','Tỉnh miền Tây, cửa ngõ sông nước và du lịch miệt vườn.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(58,'Trà Vinh','tra-vinh','province','Tỉnh miền Tây có nhiều di sản văn hoá Khmer.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(59,'Tuyên Quang','tuyen-quang','province','Tỉnh miền núi phía Bắc với nhiều di tích lịch sử cách mạng.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(60,'Vĩnh Long','vinh-long','province','Tỉnh miền Tây sông nước, nổi tiếng chợ nổi và miệt vườn.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(61,'Vĩnh Phúc','vinh-phuc','province','Tỉnh gần Hà Nội, có khu công nghiệp và cảnh quan núi Tam Đảo.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(62,'Yên Bái','yen-bai','province','Tỉnh miền núi với ruộng bậc thang Mù Cang Chải và bản làng.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31'),(63,'Hồ Chí Minh','ho-chi-minh','province','Trung tâm kinh tế lớn nhất cả nước, sôi động về đêm.','https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','2025-10-28 10:15:31','2025-10-28 10:15:31');
/*!40000 ALTER TABLE `areas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attraction_bookings`
--

DROP TABLE IF EXISTS `attraction_bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attraction_bookings` (
  `booking_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `attraction_id` int NOT NULL,
  `booking_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `num_adults` int NOT NULL DEFAULT '1',
  `total_price` decimal(12,2) NOT NULL,
  `currency_code` varchar(3) NOT NULL,
  `booking_status` enum('cancelled','completed','confirmed','pending','refunded') NOT NULL,
  `e_ticket_url` varchar(512) DEFAULT NULL,
  `qr_code_data` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `provider_id` int DEFAULT NULL,
  `channel` varchar(100) DEFAULT NULL,
  `hold_until` datetime DEFAULT NULL,
  `provider_seen` tinyint(1) NOT NULL DEFAULT '0',
  `provider_notes` text,
  `provider_confirmed` int NOT NULL,
  `provider_confirmed_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`booking_id`),
  KEY `fk_attr_booking_user` (`user_id`),
  KEY `fk_attr_booking_attr` (`attraction_id`),
  KEY `idx_attr_bookings_provider` (`provider_id`),
  KEY `idx_attr_bookings_status` (`booking_status`),
  CONSTRAINT `fk_attr_booking_attr` FOREIGN KEY (`attraction_id`) REFERENCES `attractions` (`attraction_id`),
  CONSTRAINT `fk_attr_booking_provider` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`provider_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_attr_booking_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attraction_bookings`
--

LOCK TABLES `attraction_bookings` WRITE;
/*!40000 ALTER TABLE `attraction_bookings` DISABLE KEYS */;
INSERT INTO `attraction_bookings` VALUES (1,1,2,'2025-12-10 12:48:26','2025-12-11',NULL,1,1000000.00,'VND','confirmed',NULL,NULL,'2025-12-10 12:48:26','2025-12-10 13:14:51',1,NULL,NULL,0,'people=1',1,'2025-12-10 13:14:46.163678'),(2,1,2,'2025-12-10 13:57:51','2025-12-11',NULL,2,2000000.00,'VND','pending',NULL,NULL,'2025-12-10 13:57:51','2025-12-10 13:57:51',1,NULL,NULL,0,'people=2',0,NULL);
/*!40000 ALTER TABLE `attraction_bookings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attraction_payments`
--

DROP TABLE IF EXISTS `attraction_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attraction_payments` (
  `payment_id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `user_id` int NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `currency_code` varchar(3) NOT NULL,
  `payment_method` enum('counter','mastercard','momo','other','paypal','visa','vnpay','zalopay') NOT NULL,
  `transaction_id` varchar(255) NOT NULL,
  `payment_status` enum('failed','pending','refunded','success') NOT NULL,
  `payment_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`payment_id`),
  UNIQUE KEY `transaction_id` (`transaction_id`),
  KEY `fk_attr_pay_booking` (`booking_id`),
  KEY `fk_attr_pay_user` (`user_id`),
  CONSTRAINT `fk_attr_pay_booking` FOREIGN KEY (`booking_id`) REFERENCES `attraction_bookings` (`booking_id`),
  CONSTRAINT `fk_attr_pay_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attraction_payments`
--

LOCK TABLES `attraction_payments` WRITE;
/*!40000 ALTER TABLE `attraction_payments` DISABLE KEYS */;
INSERT INTO `attraction_payments` VALUES (1,1,1,1000000.00,'VND','counter','ATTXN_1_1765370906316','pending','2025-12-10 12:48:26','2025-12-10 12:48:26','2025-12-10 12:48:26'),(2,2,1,2000000.00,'VND','counter','ATTXN_2_1765375070961','pending','2025-12-10 13:57:51','2025-12-10 13:57:51','2025-12-10 13:57:51');
/*!40000 ALTER TABLE `attraction_payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attraction_rating_summaries`
--

DROP TABLE IF EXISTS `attraction_rating_summaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attraction_rating_summaries` (
  `attraction_id` int NOT NULL,
  `avg_rating` decimal(3,2) NOT NULL DEFAULT '0.00',
  `total_reviews` int NOT NULL DEFAULT '0',
  `count_1` int NOT NULL DEFAULT '0',
  `count_2` int NOT NULL DEFAULT '0',
  `count_3` int NOT NULL DEFAULT '0',
  `count_4` int NOT NULL DEFAULT '0',
  `count_5` int NOT NULL DEFAULT '0',
  `avg_beauty` decimal(3,2) DEFAULT NULL,
  `avg_culture` decimal(3,2) DEFAULT NULL,
  `avg_accessibility` decimal(3,2) DEFAULT NULL,
  `avg_price` decimal(3,2) DEFAULT NULL,
  `avg_facilities` decimal(3,2) DEFAULT NULL,
  PRIMARY KEY (`attraction_id`),
  CONSTRAINT `fk_attr_rating` FOREIGN KEY (`attraction_id`) REFERENCES `attractions` (`attraction_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attraction_rating_summaries`
--

LOCK TABLES `attraction_rating_summaries` WRITE;
/*!40000 ALTER TABLE `attraction_rating_summaries` DISABLE KEYS */;
/*!40000 ALTER TABLE `attraction_rating_summaries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attraction_review_aspects`
--

DROP TABLE IF EXISTS `attraction_review_aspects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attraction_review_aspects` (
  `review_id` int NOT NULL,
  `beauty` tinyint NOT NULL,
  `culture` tinyint NOT NULL,
  `accessibility` tinyint NOT NULL,
  `price` tinyint NOT NULL,
  `facilities` tinyint NOT NULL,
  PRIMARY KEY (`review_id`),
  CONSTRAINT `fk_attr_aspects_review` FOREIGN KEY (`review_id`) REFERENCES `attraction_reviews` (`review_id`) ON DELETE CASCADE,
  CONSTRAINT `attraction_review_aspects_chk_1` CHECK ((`beauty` between 1 and 5)),
  CONSTRAINT `attraction_review_aspects_chk_2` CHECK ((`culture` between 1 and 5)),
  CONSTRAINT `attraction_review_aspects_chk_3` CHECK ((`accessibility` between 1 and 5)),
  CONSTRAINT `attraction_review_aspects_chk_4` CHECK ((`price` between 1 and 5)),
  CONSTRAINT `attraction_review_aspects_chk_5` CHECK ((`facilities` between 1 and 5))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attraction_review_aspects`
--

LOCK TABLES `attraction_review_aspects` WRITE;
/*!40000 ALTER TABLE `attraction_review_aspects` DISABLE KEYS */;
/*!40000 ALTER TABLE `attraction_review_aspects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attraction_reviews`
--

DROP TABLE IF EXISTS `attraction_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attraction_reviews` (
  `review_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `attraction_id` int NOT NULL,
  `rating` int NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `content` text NOT NULL,
  `image_urls` text,
  `likes_count` int NOT NULL DEFAULT '0',
  `reply_count` int NOT NULL DEFAULT '0',
  `review_status` enum('approved','rejected') NOT NULL DEFAULT 'approved',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`review_id`),
  KEY `fk_attr_review_user` (`user_id`),
  KEY `fk_attr_review_attr` (`attraction_id`),
  CONSTRAINT `fk_attr_review_attr` FOREIGN KEY (`attraction_id`) REFERENCES `attractions` (`attraction_id`),
  CONSTRAINT `fk_attr_review_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `attraction_reviews_chk_1` CHECK ((`rating` between 1 and 5))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attraction_reviews`
--

LOCK TABLES `attraction_reviews` WRITE;
/*!40000 ALTER TABLE `attraction_reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `attraction_reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attractions`
--

DROP TABLE IF EXISTS `attractions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attractions` (
  `attraction_id` int NOT NULL AUTO_INCREMENT,
  `provider_id` int NOT NULL,
  `area_id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `service_description` text,
  `location` varchar(255) DEFAULT NULL COMMENT 'Tỉnh/thành phố (tên)',
  `address` varchar(255) DEFAULT NULL COMMENT 'Địa chỉ đầy đủ',
  `latitude` decimal(10,8) DEFAULT NULL COMMENT 'Latitude coordinate',
  `longitude` decimal(11,8) DEFAULT NULL COMMENT 'Longitude coordinate',
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `price` decimal(12,2) NOT NULL,
  `currency_code` varchar(3) NOT NULL DEFAULT 'VND',
  `capacity` int DEFAULT NULL COMMENT 'Số lượng khách tối đa',
  `min_participants` int DEFAULT NULL,
  `max_participants` int DEFAULT NULL,
  `thumbnail_url` varchar(512) DEFAULT NULL,
  `image_urls` json DEFAULT NULL COMMENT 'Array of image URLs (JSON)',
  `badges` varchar(255) DEFAULT NULL,
  `attraction_status` enum('archived','disabled','published') NOT NULL,
  `visibility` enum('private_','public_') NOT NULL,
  `is_featured` tinyint(1) NOT NULL DEFAULT '0',
  `attraction_type` enum('cultural_site','entertainment','historical_site','landmark','museum','natural_attraction','other','park','temple','theme_park') DEFAULT NULL,
  `average_visit_minutes` int DEFAULT NULL COMMENT 'Thời gian tham quan trung bình (phút)',
  `visit_types_json` json DEFAULT NULL COMMENT 'Array of visit types: ["guided_tour","self_guided","audio_guide","virtual_tour"]',
  `available_times_json` json DEFAULT NULL COMMENT 'Array of time slots available',
  `suitable_for_json` json DEFAULT NULL COMMENT 'Array: ["family","kids","elderly","couples","groups","solo","pets"]',
  `features_json` json DEFAULT NULL COMMENT 'Array of feature IDs from attractions_features dictionary',
  `opening_hours_json` json DEFAULT NULL COMMENT 'Object: {"monday":"08:00-17:00","tuesday":"08:00-17:00",...}',
  `highlights_json` json DEFAULT NULL COMMENT 'Array of highlight IDs (giống hotels)',
  `tips_text` text COMMENT 'Lời khuyên cho du khách',
  `policies_text` text COMMENT 'Chính sách (hủy, hoàn tiền, quy định)',
  `slug` varchar(255) DEFAULT NULL,
  `seo_title` varchar(255) DEFAULT NULL,
  `seo_description` varchar(512) DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`attraction_id`),
  UNIQUE KEY `uq_attractions_slug` (`slug`),
  KEY `fk_attractions_area` (`area_id`),
  KEY `idx_attractions_provider` (`provider_id`),
  KEY `idx_attractions_status` (`attraction_status`),
  KEY `idx_attractions_type` (`attraction_type`),
  KEY `idx_attractions_featured` (`is_featured`),
  CONSTRAINT `fk_attractions_area` FOREIGN KEY (`area_id`) REFERENCES `areas` (`area_id`),
  CONSTRAINT `fk_attractions_provider` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`provider_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attractions`
--

LOCK TABLES `attractions` WRITE;
/*!40000 ALTER TABLE `attractions` DISABLE KEYS */;
INSERT INTO `attractions` VALUES (1,1,24,'bảo tàng','sdfhgjhsdfgjhgsdjfgjshdf','Hà Nội','Blackbox, 56, Phố Nguyễn Khuyến, Phường Văn Miếu - Quốc Tử Giám, Hà Nội, 11508, Việt Nam',21.02825329,105.83949270,'2025-12-05','2025-12-26',1.00,'VND',21,21,21,'https://res.cloudinary.com/tripfinity-img/image/upload/v1764930817/assets/066b8a95-8c31-4dba-8b30-95917db9b3f0.png','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1764930820/assets/a4eea4e4-874c-4ae1-b6df-313a51fcc810.png\"]','Hot Deal','published','private_',1,'temple',100,'[\"guided_tour\"]','[\"evening\"]','[\"groups\", \"solo\"]','[3, 8]','{\"friday\": \"213\", \"monday\": \"321\", \"sunday\": \"321\", \"tuesday\": \"132\", \"saturday\": \"321\", \"thursday\": \"23\", \"wednesday\": \"123\"}','[22, 21]','213','231','bao-tang-394169612','312','231',NULL,'2025-12-05 10:33:40','2025-12-12 11:54:00'),(2,1,15,'bảo tàng việt nam đà nẵng','điểm tham quan việt nam','Đà Nẵng','Việt nam, Đường Hoàng Sĩ Khải, Phường An Hải, Thành phố Đà Nẵng, 50207, Việt Nam',16.07640490,108.23210220,'2025-12-06','2025-12-20',1000000.00,'VND',20,1,20,'https://res.cloudinary.com/tripfinity-img/image/upload/v1765029990/assets/0bad3040-c68f-4883-86c8-b83fd18ba3e5.png','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1765029992/assets/9301c5a6-47ef-4064-bc0a-372057002165.jpg\", \"https://res.cloudinary.com/tripfinity-img/image/upload/v1765029995/assets/4d421ea0-80c2-4f31-ba14-c14d537fb2d9.png\", \"https://res.cloudinary.com/tripfinity-img/image/upload/v1765029999/assets/3f746189-607b-43bb-bf5b-c06081a06d51.png\"]','Hot Deal,Recommended','published','public_',1,'other',100,'[\"guided_tour\"]','[\"morning\"]','[\"groups\", \"solo\"]','[3, 8, 13]','{\"friday\": \"Đóng cửa\", \"monday\": \"Đóng cửa\", \"sunday\": \"Đóng cửa\", \"tuesday\": \"\", \"saturday\": \"21:10-22:00\", \"thursday\": \"Đóng cửa\", \"wednesday\": \"09:05-17:02\"}','[15, 13, 14, 20, 24, 23]','không có lời khuyên','chính sách bảo tàng','bao-tang-viet-nam-da-nang-775533657','bảo tàng việt nam đà nẵng','bảo tàng việt nam đà nẵng mô tả',NULL,'2025-12-06 14:06:40','2025-12-06 14:13:08'),(3,1,15,'21 331','1231231','Đà Nẵng','51, Kiệt 02 Tôn Thất Đạm, Xuân Hà, Phường Thanh Khê, Thành phố Đà Nẵng, 50207, Việt Nam',16.07200012,108.19931852,'2025-12-06','2026-01-03',13131.00,'VND',123,123,123,'https://res.cloudinary.com/tripfinity-img/image/upload/v1765030321/assets/2eeb3267-631f-4fd6-a6d1-0e1e3c0325bf.png','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1765030322/assets/bc935634-aa18-4daf-a90e-8829aecac702.jpg\"]','Popular','published','public_',1,'entertainment',123,'[\"guided_tour\"]','[\"morning\"]','[\"family\", \"solo\"]','[7, 6, 10]','{\"friday\": \"\", \"monday\": \"Đóng cửa\", \"sunday\": \"\", \"tuesday\": \"\", \"saturday\": \"\", \"thursday\": \"Đóng cửa\", \"wednesday\": \"\"}','[7, 12, 16]','12312','123312','21-331-690407281','21331','132123',NULL,'2025-12-06 14:12:03','2025-12-06 14:12:03');
/*!40000 ALTER TABLE `attractions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `badges`
--

DROP TABLE IF EXISTS `badges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `badges` (
  `badge_id` int NOT NULL AUTO_INCREMENT,
  `badge_name` varchar(255) NOT NULL,
  `badge_description` text,
  `icon_url` varchar(512) DEFAULT NULL,
  `criteria_json` longtext NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`badge_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `badges`
--

LOCK TABLES `badges` WRITE;
/*!40000 ALTER TABLE `badges` DISABLE KEYS */;
INSERT INTO `badges` VALUES (1,'Đồng','Du khách mới - Bắt đầu hành trình khám phá','?','{\"requiredPoints\":200}','2025-12-12 22:18:03','2025-12-12 22:18:03'),(2,'Bạc','Nhà thám hiểm - Đã có nhiều trải nghiệm','?','{\"requiredPoints\":500}','2025-12-12 22:18:03','2025-12-12 22:18:03'),(3,'Vàng','Du lịch chuyên nghiệp - Người đi nhiều nơi','?','{\"requiredPoints\":1000}','2025-12-12 22:18:03','2025-12-12 22:18:03'),(4,'Kim cương','Huyền thoại du lịch - Bậc thầy khám phá','?','{\"requiredPoints\":2000}','2025-12-12 22:18:03','2025-12-12 22:18:03'),(11,'Huyền thoại','Bậc thầy du lịch - Đỉnh cao của du lịch','?','{\"requiredPoints\":5000}','2025-12-12 22:20:10','2025-12-12 22:20:10');
/*!40000 ALTER TABLE `badges` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blogs`
--

DROP TABLE IF EXISTS `blogs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blogs` (
  `blog_id` int NOT NULL AUTO_INCREMENT,
  `blogger_id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `content` longtext NOT NULL,
  `cover_image_url` varchar(512) DEFAULT NULL,
  `tags` varchar(255) DEFAULT NULL,
  `views_count` int NOT NULL DEFAULT '0',
  `likes_count` int NOT NULL DEFAULT '0',
  `blog_status` enum('published','archived') NOT NULL DEFAULT 'published',
  `published_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`blog_id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `fk_blog_blogger` (`blogger_id`),
  CONSTRAINT `fk_blog_blogger` FOREIGN KEY (`blogger_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blogs`
--

LOCK TABLES `blogs` WRITE;
/*!40000 ALTER TABLE `blogs` DISABLE KEYS */;
/*!40000 ALTER TABLE `blogs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_messages`
--

DROP TABLE IF EXISTS `chat_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat_messages` (
  `message_id` int NOT NULL AUTO_INCREMENT,
  `sender_id` int NOT NULL,
  `receiver_id` int NOT NULL,
  `hotel_booking_id` int DEFAULT NULL,
  `restaurant_booking_id` int DEFAULT NULL,
  `attraction_booking_id` int DEFAULT NULL,
  `tour_booking_id` int DEFAULT NULL,
  `content` text NOT NULL,
  `message_type` enum('text','image','file','system') NOT NULL DEFAULT 'text',
  `attachment_url` varchar(512) DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`message_id`),
  KEY `fk_chat_sender` (`sender_id`),
  KEY `fk_chat_receiver` (`receiver_id`),
  KEY `fk_chat_hotel_booking` (`hotel_booking_id`),
  KEY `fk_chat_rest_booking` (`restaurant_booking_id`),
  KEY `fk_chat_attr_booking` (`attraction_booking_id`),
  KEY `fk_chat_tour_booking` (`tour_booking_id`),
  CONSTRAINT `fk_chat_attr_booking` FOREIGN KEY (`attraction_booking_id`) REFERENCES `attraction_bookings` (`booking_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_chat_hotel_booking` FOREIGN KEY (`hotel_booking_id`) REFERENCES `hotel_bookings` (`booking_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_chat_receiver` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_chat_rest_booking` FOREIGN KEY (`restaurant_booking_id`) REFERENCES `restaurant_bookings` (`booking_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_chat_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_chat_tour_booking` FOREIGN KEY (`tour_booking_id`) REFERENCES `tour_bookings` (`booking_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_messages`
--

LOCK TABLES `chat_messages` WRITE;
/*!40000 ALTER TABLE `chat_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `chat_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chatbot_logs`
--

DROP TABLE IF EXISTS `chatbot_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chatbot_logs` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `session_id` varchar(255) NOT NULL,
  `query_text` text NOT NULL,
  `intent_detected` varchar(255) DEFAULT NULL,
  `response_text` text NOT NULL,
  `chatbot_log_language` varchar(10) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `fk_chatbot_user` (`user_id`),
  CONSTRAINT `fk_chatbot_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chatbot_logs`
--

LOCK TABLES `chatbot_logs` WRITE;
/*!40000 ALTER TABLE `chatbot_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `chatbot_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `currencies`
--

DROP TABLE IF EXISTS `currencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `currencies` (
  `currency_code` char(3) NOT NULL,
  `currency_name` varchar(100) NOT NULL,
  `exchange_rate_to_base` decimal(18,6) NOT NULL,
  `last_updated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`currency_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `currencies`
--

LOCK TABLES `currencies` WRITE;
/*!40000 ALTER TABLE `currencies` DISABLE KEYS */;
/*!40000 ALTER TABLE `currencies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `follow`
--

DROP TABLE IF EXISTS `follow`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `follow` (
  `follow_id` int NOT NULL AUTO_INCREMENT,
  `follower_id` int NOT NULL,
  `followed_blogger_id` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`follow_id`),
  KEY `fk_follow_follower` (`follower_id`),
  KEY `fk_follow_followed` (`followed_blogger_id`),
  CONSTRAINT `fk_follow_followed` FOREIGN KEY (`followed_blogger_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_follow_follower` FOREIGN KEY (`follower_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `follow`
--

LOCK TABLES `follow` WRITE;
/*!40000 ALTER TABLE `follow` DISABLE KEYS */;
/*!40000 ALTER TABLE `follow` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hotel_bookings`
--

DROP TABLE IF EXISTS `hotel_bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hotel_bookings` (
  `booking_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `hotel_id` int NOT NULL,
  `booking_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `num_adults` int NOT NULL DEFAULT '1',
  `total_price` decimal(12,2) NOT NULL,
  `currency_code` varchar(3) NOT NULL,
  `booking_status` enum('cancelled','checked_out','completed','confirmed','pending','refunded') NOT NULL,
  `e_ticket_url` varchar(512) DEFAULT NULL,
  `qr_code_data` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `provider_id` int DEFAULT NULL,
  `channel` varchar(100) DEFAULT NULL,
  `hold_until` datetime DEFAULT NULL,
  `provider_seen` tinyint(1) NOT NULL DEFAULT '0',
  `provider_notes` text,
  `provider_confirmed` int NOT NULL,
  `provider_confirmed_at` timestamp NULL DEFAULT NULL,
  `rooms` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`booking_id`),
  KEY `fk_hotel_booking_user` (`user_id`),
  KEY `fk_hotel_booking_hotel` (`hotel_id`),
  KEY `idx_hotel_bookings_provider` (`provider_id`),
  KEY `idx_hotel_bookings_status` (`booking_status`),
  CONSTRAINT `fk_hotel_booking_hotel` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`hotel_id`),
  CONSTRAINT `fk_hotel_booking_provider` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`provider_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_hotel_booking_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hotel_bookings`
--

LOCK TABLES `hotel_bookings` WRITE;
/*!40000 ALTER TABLE `hotel_bookings` DISABLE KEYS */;
INSERT INTO `hotel_bookings` VALUES (1,1,1,'2025-10-28 04:11:00','2025-10-28','2025-10-29',2,2502446.00,'VND','confirmed',NULL,NULL,'2025-10-28 04:11:00','2025-10-28 04:11:00',NULL,'mobile_app',NULL,0,'rooms=2; beds=1',0,NULL,1),(2,1,1,'2025-10-28 04:12:16','2025-10-28','2025-10-29',2,2502446.00,'VND','pending',NULL,NULL,'2025-10-28 04:12:16','2025-10-28 04:12:16',NULL,NULL,NULL,0,'rooms=2; beds=1',0,NULL,1),(3,1,1,'2025-11-16 07:50:00','2025-11-16','2025-11-17',2,1251223.00,'VND','pending',NULL,NULL,'2025-11-16 07:50:00','2025-11-16 07:50:00',NULL,NULL,NULL,0,'rooms=1; beds=1',0,NULL,1),(4,1,1,'2025-11-16 07:57:40','2025-11-16','2025-11-17',2,1251223.00,'VND','cancelled',NULL,NULL,'2025-11-16 07:57:40','2025-11-18 09:25:50',1,NULL,NULL,0,'rooms=1; beds=1',2,'2025-11-18 02:25:50',1),(5,1,1,'2025-11-16 08:23:46','2025-11-16','2025-11-17',2,2502446.00,'VND','cancelled',NULL,NULL,'2025-11-16 08:23:46','2025-11-18 09:20:09',1,NULL,NULL,0,'rooms=2; beds=2',2,'2025-11-18 02:20:09',1),(6,1,1,'2025-11-16 08:27:39','2025-11-16','2025-11-17',2,1251223.00,'VND','cancelled',NULL,NULL,'2025-11-16 08:27:39','2025-11-18 09:20:07',1,NULL,NULL,0,'rooms=1; beds=3',2,'2025-11-18 02:20:07',1),(7,1,1,'2025-11-16 08:31:45','2025-11-16','2025-11-17',2,1251223.00,'VND','confirmed',NULL,NULL,'2025-11-16 08:31:45','2025-11-18 09:25:44',1,NULL,NULL,0,'rooms=1; beds=1',1,'2025-11-18 02:25:44',1),(8,1,1,'2025-11-16 08:35:19','2025-11-16','2025-11-17',2,1251223.00,'VND','confirmed',NULL,NULL,'2025-11-16 08:35:19','2025-11-18 09:12:30',1,NULL,NULL,0,'rooms=1; beds=1',1,'2025-11-18 02:12:30',1),(9,1,1,'2025-11-16 14:57:24','2025-11-16','2025-11-17',2,3753669.00,'VND','cancelled',NULL,NULL,'2025-11-16 14:57:24','2025-11-18 09:20:19',1,NULL,NULL,0,'rooms=3; beds=1',2,'2025-11-18 02:20:19',1),(10,1,1,'2025-11-18 09:41:56','2025-11-18','2025-11-19',12,7507338.00,'VND','confirmed',NULL,NULL,'2025-11-18 09:41:56','2025-11-18 13:30:51',1,'mobile_app',NULL,0,'rooms=6; beds=33',1,'2025-11-18 06:30:51',1),(11,1,1,'2025-11-19 08:52:22','2025-11-19','2025-11-20',2,1251223.00,'VND','cancelled',NULL,NULL,'2025-11-19 08:52:22','2025-11-22 12:30:31',1,NULL,NULL,0,'rooms=1; beds=1',2,'2025-11-22 05:30:31',1),(12,1,1,'2025-11-19 10:10:56','2025-11-19','2025-11-20',2,1251223.00,'VND','confirmed',NULL,NULL,'2025-11-19 10:10:56','2025-11-22 12:30:28',1,NULL,NULL,0,'rooms=1; beds=1',1,'2025-11-22 05:30:28',1),(13,1,1,'2025-11-22 12:31:48','2025-11-22','2025-11-23',12,1251223.00,'VND','confirmed',NULL,NULL,'2025-11-22 12:31:48','2025-11-30 10:32:45',1,NULL,NULL,0,'rooms=1; beds=1',1,'2025-11-30 03:32:41',1),(14,1,1,'2025-11-23 14:02:47','2025-11-23','2025-11-24',2,47546474.00,'VND','confirmed',NULL,NULL,'2025-11-23 14:02:47','2025-11-30 10:18:37',1,NULL,NULL,0,'rooms=38; beds=1',1,'2025-11-30 03:18:34',1),(15,1,1,'2025-11-23 14:06:48','2025-11-23','2025-11-24',2,48797697.00,'VND','confirmed',NULL,NULL,'2025-11-23 14:06:48','2025-11-27 15:32:11',1,NULL,NULL,0,'rooms=39; beds=1',1,'2025-11-27 08:32:07',1),(16,1,3,'2025-11-23 14:08:39','2025-11-23','2025-11-24',2,13781340.00,'VND','confirmed',NULL,NULL,'2025-11-23 14:08:39','2025-11-27 15:29:37',1,NULL,NULL,0,'rooms=4; beds=1',1,'2025-11-27 08:29:33',1),(17,1,3,'2025-11-23 14:15:44','2025-11-23','2025-11-24',2,20672010.00,'VND','confirmed',NULL,NULL,'2025-11-23 14:15:44','2025-11-27 15:29:24',1,NULL,NULL,0,'rooms=6; beds=1',1,'2025-11-27 08:29:20',1),(18,1,1,'2025-11-23 14:56:36','2025-11-23','2025-11-24',2,27526906.00,'VND','confirmed',NULL,NULL,'2025-11-23 14:56:36','2025-11-26 08:32:30',1,NULL,NULL,0,'rooms=22; beds=1',1,'2025-11-26 01:32:30',22),(19,1,4,'2025-11-27 14:24:13','2025-11-27','2025-11-28',2,1123336.00,'VND','cancelled',NULL,NULL,'2025-11-27 14:24:13','2025-11-27 15:16:50',1,NULL,NULL,0,'rooms=1; beds=1',2,'2025-11-27 08:16:46',1),(20,1,2,'2025-11-27 14:59:41','2025-11-27','2025-11-28',2,1666666.00,'VND','confirmed',NULL,NULL,'2025-11-27 14:59:41','2025-11-27 15:15:53',1,NULL,NULL,0,'rooms=1; beds=1',1,'2025-11-27 08:15:49',1),(21,1,2,'2025-11-30 09:06:50','2025-11-30','2025-12-01',2,1666666.00,'VND','confirmed',NULL,NULL,'2025-11-30 09:06:50','2025-11-30 09:37:30',1,'mobile_app',NULL,0,'rooms=1; beds=1',1,'2025-11-30 02:37:27',1),(22,1,2,'2025-11-30 09:08:50','2025-11-30','2025-12-01',2,1666666.00,'VND','confirmed',NULL,NULL,'2025-11-30 09:08:50','2025-11-30 09:30:47',1,NULL,NULL,0,'rooms=1; beds=1',1,'2025-11-30 02:30:44',1),(23,1,2,'2025-11-30 09:11:24','2025-11-30','2025-12-01',2,1666666.00,'VND','confirmed',NULL,NULL,'2025-11-30 09:11:24','2025-11-30 09:13:19',1,'mobile_app',NULL,0,'rooms=1; beds=1',1,'2025-11-30 02:13:16',1),(24,1,4,'2025-11-30 09:20:13','2025-11-30','2025-12-01',2,1123336.00,'VND','confirmed',NULL,NULL,'2025-11-30 09:20:13','2025-11-30 09:20:59',1,NULL,NULL,0,'rooms=1; beds=1',1,'2025-11-30 02:20:55',1),(25,1,4,'2025-11-30 10:04:05','2025-11-30','2025-12-01',2,1123336.00,'VND','confirmed',NULL,NULL,'2025-11-30 10:04:05','2025-11-30 10:04:34',1,NULL,NULL,0,'rooms=1; beds=1',1,'2025-11-30 03:04:30',1),(26,1,4,'2025-11-30 10:10:56','2025-11-30','2025-12-01',2,1123336.00,'VND','confirmed',NULL,NULL,'2025-11-30 10:10:56','2025-11-30 10:11:21',1,NULL,NULL,0,'rooms=1; beds=1',1,'2025-11-30 03:11:15',1),(27,1,4,'2025-11-30 10:34:36','2025-11-30','2025-12-01',2,1123336.00,'VND','cancelled',NULL,NULL,'2025-11-30 10:34:36','2025-11-30 10:35:11',1,NULL,NULL,0,'rooms=1; beds=1',2,'2025-11-30 03:35:07',1),(28,1,4,'2025-11-30 10:36:15','2025-11-30','2025-12-01',2,1123336.00,'VND','confirmed',NULL,NULL,'2025-11-30 10:36:15','2025-11-30 10:36:34',1,NULL,NULL,0,'rooms=1; beds=1',1,'2025-11-30 03:36:31',1),(29,1,4,'2025-11-30 10:43:19','2025-11-30','2025-12-01',2,1123336.00,'VND','cancelled',NULL,NULL,'2025-11-30 10:43:19','2025-11-30 10:43:48',1,NULL,NULL,0,'rooms=1; beds=1',2,'2025-11-30 03:43:44',1),(30,1,4,'2025-11-30 11:07:32','2025-11-30','2025-12-01',2,1123336.00,'VND','confirmed',NULL,NULL,'2025-11-30 11:07:32','2025-11-30 11:07:47',1,NULL,NULL,0,'rooms=1; beds=1',1,'2025-11-30 04:07:43',1),(31,1,4,'2025-11-30 11:08:13','2025-11-30','2025-12-01',2,1123336.00,'VND','cancelled',NULL,NULL,'2025-11-30 11:08:13','2025-11-30 11:08:32',1,NULL,NULL,0,'rooms=1; beds=1',2,'2025-11-30 04:08:28',1),(32,1,4,'2025-11-30 11:12:26','2025-11-30','2025-12-01',2,1123336.00,'VND','confirmed',NULL,NULL,'2025-11-30 11:12:26','2025-11-30 11:18:02',1,NULL,NULL,0,'rooms=1; beds=1',1,'2025-11-30 04:17:58',1),(33,1,4,'2025-11-30 11:12:44','2025-11-30','2025-12-01',2,1123336.00,'VND','confirmed',NULL,NULL,'2025-11-30 11:12:44','2025-11-30 11:13:18',1,NULL,NULL,0,'rooms=1; beds=1',1,'2025-11-30 04:13:14',1),(34,1,4,'2025-11-30 11:24:09','2025-11-30','2025-12-01',2,1123336.00,'VND','confirmed',NULL,NULL,'2025-11-30 11:24:09','2025-12-08 07:22:36',1,NULL,NULL,0,'rooms=1; beds=1',1,'2025-12-08 00:22:33',1),(35,1,4,'2025-11-30 11:24:29','2025-11-30','2025-12-01',2,1123336.00,'VND','cancelled',NULL,NULL,'2025-11-30 11:24:29','2025-11-30 11:28:15',1,NULL,NULL,0,'rooms=1; beds=1',2,'2025-11-30 04:28:12',1),(36,1,4,'2025-11-30 11:24:53','2025-11-30','2025-12-01',2,1123336.00,'VND','confirmed',NULL,NULL,'2025-11-30 11:24:53','2025-11-30 11:28:04',1,NULL,NULL,0,'rooms=1; beds=1',1,'2025-11-30 04:28:00',1),(37,1,4,'2025-11-30 11:25:07','2025-11-30','2025-12-01',2,1123336.00,'VND','confirmed',NULL,NULL,'2025-11-30 11:25:07','2025-11-30 11:25:24',1,NULL,NULL,0,'rooms=1; beds=1',1,'2025-11-30 04:25:20',1),(38,1,4,'2025-11-30 11:37:51','2025-11-30','2025-12-01',2,1123336.00,'VND','confirmed',NULL,NULL,'2025-11-30 11:37:51','2025-11-30 11:38:09',1,NULL,NULL,0,'rooms=1; beds=1',1,'2025-11-30 04:38:05',1),(39,1,15,'2025-12-08 07:47:39','2025-12-08','2025-12-09',2,223.00,'VND','pending',NULL,NULL,'2025-12-08 07:47:39','2025-12-08 07:47:39',1,NULL,NULL,0,'rooms=1; beds=1',0,NULL,1),(40,1,16,'2025-12-12 15:28:29','2025-12-12','2025-12-13',2,112335.00,'VND','confirmed',NULL,NULL,'2025-12-12 15:28:29','2025-12-12 15:28:57',1,NULL,NULL,0,'rooms=1; beds=1',1,'2025-12-12 08:28:53',1);
/*!40000 ALTER TABLE `hotel_bookings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hotel_payments`
--

DROP TABLE IF EXISTS `hotel_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hotel_payments` (
  `payment_id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `user_id` int NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `currency_code` varchar(3) NOT NULL,
  `payment_method` enum('counter','mastercard','momo','other','paypal','visa','vnpay','zalopay') NOT NULL,
  `transaction_id` varchar(255) NOT NULL,
  `payment_status` enum('failed','pending','refunded','success') NOT NULL,
  `payment_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`payment_id`),
  UNIQUE KEY `transaction_id` (`transaction_id`),
  KEY `fk_hotel_pay_booking` (`booking_id`),
  KEY `fk_hotel_pay_user` (`user_id`),
  CONSTRAINT `fk_hotel_pay_booking` FOREIGN KEY (`booking_id`) REFERENCES `hotel_bookings` (`booking_id`),
  CONSTRAINT `fk_hotel_pay_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hotel_payments`
--

LOCK TABLES `hotel_payments` WRITE;
/*!40000 ALTER TABLE `hotel_payments` DISABLE KEYS */;
INSERT INTO `hotel_payments` VALUES (1,1,1,2502446.00,'VND','zalopay','TXN_1_1761624659891','success','2025-10-28 04:11:00','2025-10-28 04:11:00','2025-10-28 04:11:00'),(2,2,1,2502446.00,'VND','counter','TXN_2_1761624735689','pending','2025-10-28 04:12:16','2025-10-28 04:12:16','2025-10-28 04:12:16'),(3,3,1,1251223.00,'VND','counter','TXN_3_1763279399782','pending','2025-11-16 07:50:00','2025-11-16 07:50:00','2025-11-16 07:50:00'),(4,4,1,1251223.00,'VND','counter','TXN_4_1763279860398','pending','2025-11-16 07:57:40','2025-11-16 07:57:40','2025-11-16 07:57:40'),(5,5,1,2502446.00,'VND','counter','TXN_5_1763281426374','pending','2025-11-16 08:23:46','2025-11-16 08:23:46','2025-11-16 08:23:46'),(6,6,1,1251223.00,'VND','counter','TXN_6_1763281658662','pending','2025-11-16 08:27:39','2025-11-16 08:27:39','2025-11-16 08:27:39'),(7,7,1,1251223.00,'VND','counter','TXN_7_1763281904587','pending','2025-11-16 08:31:45','2025-11-16 08:31:45','2025-11-16 08:31:45'),(8,8,1,1251223.00,'VND','counter','TXN_8_1763282119096','pending','2025-11-16 08:35:19','2025-11-16 08:35:19','2025-11-16 08:35:19'),(9,9,1,3753669.00,'VND','counter','TXN_9_1763305043561','pending','2025-11-16 14:57:24','2025-11-16 14:57:24','2025-11-16 14:57:24'),(10,10,1,7507338.00,'VND','zalopay','TXN_10_1763458916017','success','2025-11-18 09:41:56','2025-11-18 09:41:56','2025-11-18 09:41:56'),(11,11,1,1251223.00,'VND','counter','TXN_11_1763542342015','pending','2025-11-19 08:52:22','2025-11-19 08:52:22','2025-11-19 08:52:22'),(12,12,1,1251223.00,'VND','counter','TXN_12_1763547056394','pending','2025-11-19 10:10:56','2025-11-19 10:10:56','2025-11-19 10:10:56'),(13,13,1,1251223.00,'VND','counter','TXN_13_1763814708074','pending','2025-11-22 12:31:48','2025-11-22 12:31:48','2025-11-22 12:31:48'),(14,14,1,47546474.00,'VND','counter','TXN_14_1763906567567','pending','2025-11-23 14:02:48','2025-11-23 14:02:48','2025-11-23 14:02:48'),(15,15,1,48797697.00,'VND','counter','TXN_15_1763906808249','pending','2025-11-23 14:06:48','2025-11-23 14:06:48','2025-11-23 14:06:48'),(16,16,1,13781340.00,'VND','counter','TXN_16_1763906919397','pending','2025-11-23 14:08:39','2025-11-23 14:08:39','2025-11-23 14:08:39'),(17,17,1,20672010.00,'VND','counter','TXN_17_1763907344496','pending','2025-11-23 14:15:44','2025-11-23 14:15:44','2025-11-23 14:15:44'),(18,18,1,27526906.00,'VND','counter','TXN_18_1763909795783','pending','2025-11-23 14:56:36','2025-11-23 14:56:36','2025-11-23 14:56:36'),(19,19,1,1123336.00,'VND','counter','TXN_19_1764253452977','pending','2025-11-27 14:24:13','2025-11-27 14:24:13','2025-11-27 14:24:13'),(20,20,1,1666666.00,'VND','counter','TXN_20_1764255581177','pending','2025-11-27 14:59:41','2025-11-27 14:59:41','2025-11-27 14:59:41'),(21,21,1,1666666.00,'VND','zalopay','TXN_21_1764493610218','success','2025-11-30 09:06:50','2025-11-30 09:06:50','2025-11-30 09:06:50'),(22,22,1,1666666.00,'VND','counter','TXN_22_1764493729995','pending','2025-11-30 09:08:50','2025-11-30 09:08:50','2025-11-30 09:08:50'),(23,23,1,1666666.00,'VND','zalopay','TXN_23_1764493884041','success','2025-11-30 09:11:24','2025-11-30 09:11:24','2025-11-30 09:11:24'),(24,24,1,1123336.00,'VND','counter','TXN_24_1764494413396','pending','2025-11-30 09:20:13','2025-11-30 09:20:13','2025-11-30 09:20:13'),(25,25,1,1123336.00,'VND','counter','TXN_25_1764497044726','pending','2025-11-30 10:04:05','2025-11-30 10:04:05','2025-11-30 10:04:05'),(26,26,1,1123336.00,'VND','counter','TXN_26_1764497456257','pending','2025-11-30 10:10:56','2025-11-30 10:10:56','2025-11-30 10:10:56'),(27,27,1,1123336.00,'VND','counter','TXN_27_1764498875658','pending','2025-11-30 10:34:36','2025-11-30 10:34:36','2025-11-30 10:34:36'),(28,28,1,1123336.00,'VND','counter','TXN_28_1764498975079','pending','2025-11-30 10:36:15','2025-11-30 10:36:15','2025-11-30 10:36:15'),(29,29,1,1123336.00,'VND','counter','TXN_29_1764499398817','pending','2025-11-30 10:43:19','2025-11-30 10:43:19','2025-11-30 10:43:19'),(30,30,1,1123336.00,'VND','counter','TXN_30_1764500851920','pending','2025-11-30 11:07:32','2025-11-30 11:07:32','2025-11-30 11:07:32'),(31,31,1,1123336.00,'VND','counter','TXN_31_1764500892743','pending','2025-11-30 11:08:13','2025-11-30 11:08:13','2025-11-30 11:08:13'),(32,32,1,1123336.00,'VND','counter','TXN_32_1764501146322','pending','2025-11-30 11:12:26','2025-11-30 11:12:26','2025-11-30 11:12:26'),(33,33,1,1123336.00,'VND','counter','TXN_33_1764501163521','pending','2025-11-30 11:12:44','2025-11-30 11:12:44','2025-11-30 11:12:44'),(34,34,1,1123336.00,'VND','counter','TXN_34_1764501848584','pending','2025-11-30 11:24:09','2025-11-30 11:24:09','2025-11-30 11:24:09'),(35,35,1,1123336.00,'VND','counter','TXN_35_1764501869370','pending','2025-11-30 11:24:29','2025-11-30 11:24:29','2025-11-30 11:24:29'),(36,36,1,1123336.00,'VND','counter','TXN_36_1764501893222','pending','2025-11-30 11:24:53','2025-11-30 11:24:53','2025-11-30 11:24:53'),(37,37,1,1123336.00,'VND','counter','TXN_37_1764501906599','pending','2025-11-30 11:25:07','2025-11-30 11:25:07','2025-11-30 11:25:07'),(38,38,1,1123336.00,'VND','counter','TXN_38_1764502670997','pending','2025-11-30 11:37:51','2025-11-30 11:37:51','2025-11-30 11:37:51'),(39,39,1,223.00,'VND','counter','TXN_39_1765180058953','pending','2025-12-08 07:47:39','2025-12-08 07:47:39','2025-12-08 07:47:39'),(40,40,1,112335.00,'VND','counter','TXN_40_1765553309399','pending','2025-12-12 15:28:29','2025-12-12 15:28:29','2025-12-12 15:28:29');
/*!40000 ALTER TABLE `hotel_payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hotel_rating_summaries`
--

DROP TABLE IF EXISTS `hotel_rating_summaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hotel_rating_summaries` (
  `hotel_id` int NOT NULL,
  `avg_rating` decimal(3,2) NOT NULL DEFAULT '0.00',
  `total_reviews` int NOT NULL DEFAULT '0',
  `count_1` int NOT NULL DEFAULT '0',
  `count_2` int NOT NULL DEFAULT '0',
  `count_3` int NOT NULL DEFAULT '0',
  `count_4` int NOT NULL DEFAULT '0',
  `count_5` int NOT NULL DEFAULT '0',
  `avg_cleanliness` decimal(3,2) DEFAULT NULL,
  `avg_service` decimal(3,2) DEFAULT NULL,
  `avg_value_for_money` decimal(3,2) DEFAULT NULL,
  `avg_location` decimal(3,2) DEFAULT NULL,
  `avg_facilities` decimal(3,2) DEFAULT NULL,
  PRIMARY KEY (`hotel_id`),
  CONSTRAINT `fk_hotel_rating` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`hotel_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hotel_rating_summaries`
--

LOCK TABLES `hotel_rating_summaries` WRITE;
/*!40000 ALTER TABLE `hotel_rating_summaries` DISABLE KEYS */;
/*!40000 ALTER TABLE `hotel_rating_summaries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hotel_review_aspects`
--

DROP TABLE IF EXISTS `hotel_review_aspects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hotel_review_aspects` (
  `review_id` int NOT NULL,
  `cleanliness` int NOT NULL,
  `service` int NOT NULL,
  `value_for_money` int NOT NULL,
  `location` int NOT NULL,
  `facilities` int NOT NULL,
  PRIMARY KEY (`review_id`),
  CONSTRAINT `fk_hotel_aspects_review` FOREIGN KEY (`review_id`) REFERENCES `hotel_reviews` (`review_id`) ON DELETE CASCADE,
  CONSTRAINT `hotel_review_aspects_chk_1` CHECK ((`cleanliness` between 1 and 5)),
  CONSTRAINT `hotel_review_aspects_chk_2` CHECK ((`service` between 1 and 5)),
  CONSTRAINT `hotel_review_aspects_chk_3` CHECK ((`value_for_money` between 1 and 5)),
  CONSTRAINT `hotel_review_aspects_chk_4` CHECK ((`location` between 1 and 5)),
  CONSTRAINT `hotel_review_aspects_chk_5` CHECK ((`facilities` between 1 and 5))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hotel_review_aspects`
--

LOCK TABLES `hotel_review_aspects` WRITE;
/*!40000 ALTER TABLE `hotel_review_aspects` DISABLE KEYS */;
INSERT INTO `hotel_review_aspects` VALUES (4,4,4,4,4,4),(5,3,1,1,1,1),(6,1,4,4,2,5),(7,3,3,3,3,3),(8,1,1,1,1,1),(9,4,3,3,3,3);
/*!40000 ALTER TABLE `hotel_review_aspects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hotel_reviews`
--

DROP TABLE IF EXISTS `hotel_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hotel_reviews` (
  `review_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `hotel_id` int NOT NULL,
  `rating` int NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `content` text NOT NULL,
  `image_urls` text,
  `likes_count` int NOT NULL DEFAULT '0',
  `reply_count` int NOT NULL DEFAULT '0',
  `review_status` enum('approved','rejected') NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`review_id`),
  KEY `fk_hotel_review_user` (`user_id`),
  KEY `fk_hotel_review_hotel` (`hotel_id`),
  CONSTRAINT `fk_hotel_review_hotel` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`hotel_id`),
  CONSTRAINT `fk_hotel_review_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `hotel_reviews_chk_1` CHECK ((`rating` between 1 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hotel_reviews`
--

LOCK TABLES `hotel_reviews` WRITE;
/*!40000 ALTER TABLE `hotel_reviews` DISABLE KEYS */;
INSERT INTO `hotel_reviews` VALUES (4,1,1,5,'123123','1312','assets/images/onboarding1.png',1,1,'approved','2025-11-19 09:58:35','2025-11-22 12:31:15'),(5,1,1,3,'4545','45454545',NULL,2,0,'approved','2025-11-19 10:11:12','2025-11-22 12:31:07'),(6,1,1,4,'24','342','https://res.cloudinary.com/tripfinity-img/image/upload/v1763547129/assets/56cd11d8-19b1-4f71-b943-d91dbde79b1c.jpg',1,2,'approved','2025-11-19 10:12:00','2025-11-22 12:31:06'),(7,1,1,3,'3242','234234','https://res.cloudinary.com/tripfinity-img/image/upload/v1763563561/assets/d3e5e3df-8f40-4a74-8c0b-a9d2ca822558.jpg',1,0,'approved','2025-11-19 14:45:51','2025-11-22 12:31:04'),(8,1,1,1,'1123132123','1232132311','https://res.cloudinary.com/tripfinity-img/image/upload/v1763811909/assets/9895c2e0-b757-4ca2-8693-190dfd4180cc.jpg',1,1,'approved','2025-11-22 11:45:10','2025-11-22 11:54:28'),(9,1,15,4,'453','345',NULL,0,0,'approved','2025-12-01 14:06:08','2025-12-01 14:06:08');
/*!40000 ALTER TABLE `hotel_reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hotels`
--

DROP TABLE IF EXISTS `hotels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hotels` (
  `hotel_id` int NOT NULL AUTO_INCREMENT,
  `provider_id` int NOT NULL,
  `area_id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `service_description` text,
  `location` varchar(255) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `price` decimal(12,2) NOT NULL,
  `currency_code` varchar(3) NOT NULL,
  `capacity` int DEFAULT NULL,
  `min_participants` int DEFAULT NULL,
  `max_participants` int DEFAULT NULL,
  `thumbnail_url` varchar(512) DEFAULT NULL,
  `image_urls` text,
  `badges` varchar(255) DEFAULT NULL,
  `hotel_status` enum('archived','disabled','published') NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `seo_title` varchar(255) DEFAULT NULL,
  `seo_description` varchar(512) DEFAULT NULL,
  `is_featured` tinyint(1) NOT NULL DEFAULT '0',
  `published_at` datetime DEFAULT NULL,
  `visibility` enum('private_','public_') NOT NULL,
  `star_rating` int DEFAULT NULL,
  `property_type` enum('apartment','guesthouse','homestay','hostel','hotel','resort','villa') DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL COMMENT 'Latitude coordinate for map location',
  `longitude` decimal(11,8) DEFAULT NULL COMMENT 'Longitude coordinate for map location',
  `checkin_time` time DEFAULT NULL,
  `checkout_time` time DEFAULT NULL,
  `highlights_json` json DEFAULT NULL,
  `amenities_json` json DEFAULT NULL,
  `policies_text` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `max_beds_per_room` int DEFAULT NULL,
  `price_per_night` decimal(12,2) DEFAULT NULL,
  `total_rooms` int DEFAULT NULL,
  PRIMARY KEY (`hotel_id`),
  UNIQUE KEY `uq_hotels_slug` (`slug`),
  KEY `fk_hotels_area` (`area_id`),
  KEY `idx_hotels_provider` (`provider_id`),
  KEY `idx_hotels_status` (`hotel_status`),
  KEY `idx_hotels_location` (`latitude`,`longitude`),
  CONSTRAINT `fk_hotels_area` FOREIGN KEY (`area_id`) REFERENCES `areas` (`area_id`),
  CONSTRAINT `fk_hotels_provider` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`provider_id`),
  CONSTRAINT `hotels_chk_1` CHECK ((`star_rating` between 1 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hotels`
--

LOCK TABLES `hotels` WRITE;
/*!40000 ALTER TABLE `hotels` DISABLE KEYS */;
INSERT INTO `hotels` VALUES (1,1,1,'Khách sạn việt nam ','hjkgfsdkhgjsdfghkjsdfkhjsdfhjkdsfhjkdsf fdskjhdsfahkjsdfhkjjkhasdf kasdjfhfjkaslhjkfdasjklhfads kjsadhfasdjfaslhjfhjksladsafkhjlasdkhjfasddfasdf asdfasdfasd','Hà nội','2025-10-07','2025-10-29',1131223.00,'VND',122,12,12,'https://res.cloudinary.com/tripfinity-img/image/upload/v1761624389/assets/b07b483f-096b-4e3c-be87-99605894447b.png','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1761624391/assets/94127245-7e0b-47a0-8f23-11c252a594c1.png\",\"https://res.cloudinary.com/tripfinity-img/image/upload/v1761624396/assets/adbe2a91-f0bf-4446-b372-c23b68ffc96e.png\"]','Recommended','published','k','123213','123213',1,'2025-10-28 04:06:24','public_',4,'apartment','16.130956, 108.123200',16.13095628,108.12319989,'17:33:00','05:31:00','[3, 10, 25, 28]','[9, 6, 23]','1231231','2025-10-28 04:06:24','2025-12-01 03:28:15',11,120000.00,32),(2,1,14,'khách sạn đêm','342234','324234','2025-11-13','2025-11-22',1342342.00,'VND',10,1,10,'https://res.cloudinary.com/tripfinity-img/image/upload/v1763902483/assets/9838d72a-3061-49c1-94ed-c459a5c6be00.png','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1763902487/assets/bad9d265-125e-465c-bef3-2c747f5f51be.png\"]','Family-Friendly','published','4234234423','234234423','234234423',1,'2025-11-23 12:54:38','public_',4,'hotel','234423',NULL,NULL,NULL,NULL,'[5, 16]','[5]','324432324','2025-11-23 12:54:38','2025-11-26 09:43:46',13,324324.00,NULL),(3,1,18,'21323123','123123','2321123123','2025-11-06','2025-11-11',1312213.00,'VND',222,2,23,'https://res.cloudinary.com/tripfinity-img/image/upload/v1763905857/assets/72626772-0b5d-4154-b1f5-82dc0092d0f3.jpg',NULL,'Luxury,Popular','published','2123','213','213',1,'2025-11-23 13:50:54','public_',4,'resort','12312',NULL,NULL,'13:52:00','13:55:00','[12, 27]','[17, 22]','123312213','2025-11-23 13:50:55','2025-11-23 14:08:07',11,2133122.00,2),(4,1,18,'123231','123','123','2025-11-26','2231-12-31',1123123.00,'VND',231,123,123,'https://res.cloudinary.com/tripfinity-img/image/upload/v1763906229/assets/86aed785-98a3-4c2b-ba54-64cde1591493.png','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1763909879/assets/8fa726b1-1ab1-4627-9c53-78195e860db5.jpg\",\"https://res.cloudinary.com/tripfinity-img/image/upload/v1763909883/assets/54f13e9d-7339-4733-8c96-d1905331b642.png\"]','Popular,Luxury','published','1',NULL,NULL,0,'2025-11-23 13:57:04','public_',1,'hostel','123',NULL,NULL,'05:31:00','19:31:00','[17, 20]','[11, 16]',NULL,'2025-11-23 13:57:04','2025-11-23 14:58:04',123,213.00,213),(5,1,15,'hfhfhffh','213','213','2025-11-04','2025-11-28',1213.00,'VND',213,213,213,NULL,NULL,'Popular','published','h123',NULL,NULL,0,'2025-11-26 09:49:57','public_',4,'resort','213',NULL,NULL,'09:53:00','09:52:00','[6]','[3, 24]','213','2025-11-26 09:49:57','2025-11-26 09:49:57',11,221.00,213),(7,1,14,'khách sạn viop','231','15.541672, 108.457064','2025-12-01','2025-12-25',14.00,'VND',123,123,123,'https://res.cloudinary.com/tripfinity-img/image/upload/v1764558084/assets/079960bb-9ac3-4ac4-b54e-a63f2fd5b876.png','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1764558088/assets/c3e83052-253e-4763-b182-48f9c2c4ec56.png\"]','Popular,Luxury','published','3231','13','132',1,'2025-12-01 03:01:19','public_',3,'apartment','15.541672, 108.457064',15.54167181,108.45706358,'03:00:00','03:00:00','[7, 12]','[13, 28]','123','2025-12-01 03:01:19','2025-12-01 03:01:28',13,32.00,123),(8,1,17,'34324','342','15.593224, 108.532138','2025-12-11','2025-12-25',13.00,'VND',234,2,123,'https://res.cloudinary.com/tripfinity-img/image/upload/v1764558612/assets/1bcb5d32-4073-4bea-93df-fbee36020089.png','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1764558615/assets/fc5c8081-5b2f-4b73-8ff3-09860fb24432.jpg\"]','Hot Deal,Luxury','published','323','234','234',1,'2025-12-01 03:10:09','public_',4,'apartment','15.582900, 108.516807',15.58290021,108.51680688,'03:09:00','03:09:00','[3, 30]','[21, 20]','32','2025-12-01 03:10:10','2025-12-01 03:26:29',13,234.00,23),(10,1,15,'khách sạn đà nẵng ','12213213','Phường Điện Bàn Đông','2025-12-13','2025-12-13',11.00,'VND',123,123,123,'https://res.cloudinary.com/tripfinity-img/image/upload/v1764593788/assets/3b34d342-a662-4cc6-a647-a9f9f2e989a2.png','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1764593790/assets/b5dacf5c-793f-4b15-8b36-fc5032247616.jpg\"]','Popular,Luxury','published','k123','312','213',1,'2025-12-01 12:56:23','public_',3,'apartment','Phường Điện Bàn Đông, Thành phố Đà Nẵng, Việt Nam',15.94215490,108.29430823,'12:55:00','12:55:00','[7, 8]','[8, 9, 31, 26]','21','2025-12-01 12:56:23','2025-12-01 12:56:30',11,1.00,213),(13,1,24,'khách sạn hà nội','3231',NULL,'2025-12-06','2025-12-13',10.00,'VND',123,12,12,'https://res.cloudinary.com/tripfinity-img/image/upload/v1764594798/assets/aabfde0e-6e35-4983-a773-1631360fd81d.png','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1764594799/assets/3b3f9a2e-4e58-436d-84eb-1fec733fa1c5.jpg\"]','Hot Deal,Luxury','published','k123213 123123213123213','123','132',1,'2025-12-01 13:13:12','public_',3,'resort','135, Phố Phúc Tân, Phường Hồng Hà, Hà Nội, 11008, Việt Nam',21.03710569,105.85485639,'13:12:00','13:12:00','[11, 12]','[6, 5]','312','2025-12-01 13:13:12','2025-12-01 13:13:57',10,121.00,123),(14,1,15,'khách sạn víp đà nẵng','3123123 234234','Đà Nẵng','2025-12-05','2025-12-12',122.00,'VND',312,123,123,'https://res.cloudinary.com/tripfinity-img/image/upload/v1764595348/assets/5086362e-a5f7-40ea-a900-3d2afe4cecbd.png','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1764595349/assets/97c861c8-5d8b-4d44-9323-0f8d37180e4b.jpg\"]','Budget-Friendly,Family-Friendly','published','k12321322454565475678567 23423423','34','324',1,'2025-12-01 13:22:22','public_',3,'apartment','Đường Yên Bái, Phước Ninh, Phường Hải Châu, Thành phố Đà Nẵng, 50207, Việt Nam',16.06882477,108.22266446,'13:21:00','13:21:00','[6, 23]','[6, 3]','312','2025-12-01 13:22:22','2025-12-01 13:24:28',12,10.00,123),(15,1,58,'khách sạn bà rịa','23312123123123','TP. Hồ Chí Minh','2025-12-06','2025-12-06',100.00,'VND',21,12,12,'https://res.cloudinary.com/tripfinity-img/image/upload/v1764597749/assets/7e06be64-129d-41f7-a465-62f71f886249.png','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1764597753/assets/e276dac8-be0f-4f5c-8d61-fef9e9214233.png\"]','Popular,Recommended','published','khach-san-ba-ria-515625930','312','132',1,'2025-12-01 14:02:23','public_',2,'hotel','an bình, 2, Hùng Vương, Phường Bà Rịa, Thành phố Hồ Chí Minh, 78106, Việt Nam',10.50137309,107.17374178,'14:05:00','08:12:00','[7, 8]','[6, 9]','312','2025-12-01 14:02:23','2025-12-01 14:07:10',11,123.00,123),(16,1,15,'3123','123123123','Đà Nẵng','2025-12-02','2025-12-13',100022.00,'VND',123,123,123,'https://res.cloudinary.com/tripfinity-img/image/upload/v1764662505/assets/09651aec-8bbc-42fb-8df0-45f06338b2dd.png','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1764662507/assets/2f595468-3eac-4a60-9cd2-411ce9628000.jpg\"]','Pet-Friendly','published','3123-910508175','dâsdasdasdas','ádasdasdasdasda',1,'2025-12-02 08:01:38','public_',2,'hotel','Cầu Chìm, Xã Nam Phước, Thành phố Đà Nẵng, 51506, Việt Nam',15.82537796,108.25129515,'17:33:00','20:12:00','[3, 10]','[3, 6]','123234543assaddadasdas','2025-12-02 08:01:38','2025-12-02 08:02:30',1123123,12313.00,123),(17,1,13,'213','123123312','Cần Thơ','2025-12-23','2026-01-02',1123.00,'VND',213,123,123,NULL,NULL,'Popular','published','213-970515817','321123','213312',0,'2025-12-05 07:59:24','public_',3,'hotel','Cầu Cần Thơ, Phường Hưng Phú, Thành phố Cần Thơ, Phường Cái Vồn, Tỉnh Vĩnh Long, 94111, Việt Nam',10.03485232,105.79816610,'05:31:00','08:12:00','[7, 10]','[15]','123','2025-12-05 07:59:24','2025-12-05 07:59:24',1123,312.00,231);
/*!40000 ALTER TABLE `hotels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `image_search_logs`
--

DROP TABLE IF EXISTS `image_search_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `image_search_logs` (
  `image_search_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `image_url` varchar(512) NOT NULL,
  `result_json` longtext,
  `similarity_score` decimal(4,2) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`image_search_id`),
  KEY `fk_image_search_user` (`user_id`),
  CONSTRAINT `fk_image_search_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `image_search_logs`
--

LOCK TABLES `image_search_logs` WRITE;
/*!40000 ALTER TABLE `image_search_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `image_search_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `itineraries_downloads`
--

DROP TABLE IF EXISTS `itineraries_downloads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `itineraries_downloads` (
  `itinerary_build_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `itineraries_download_name` varchar(255) NOT NULL,
  `content_json` longtext NOT NULL,
  `share_link` varchar(512) DEFAULT NULL,
  `pdf_export_url` varchar(512) DEFAULT NULL,
  `ics_export_url` varchar(512) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`itinerary_build_id`),
  KEY `fk_itin_download_user` (`user_id`),
  CONSTRAINT `fk_itin_download_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `itineraries_downloads`
--

LOCK TABLES `itineraries_downloads` WRITE;
/*!40000 ALTER TABLE `itineraries_downloads` DISABLE KEYS */;
/*!40000 ALTER TABLE `itineraries_downloads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `notification_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `notification_type` varchar(50) NOT NULL,
  `category` varchar(100) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `content` text NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `read_at` datetime DEFAULT NULL,
  `sent_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`notification_id`),
  KEY `fk_notifications_user` (`user_id`),
  CONSTRAINT `fk_notifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=132 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,2,'in_app','service_hotel_update','Khách sạn đã được cập nhật','Thông tin khách sạn \'Khách sạn việt nam\' đã được cập nhật thành công.',1,'2025-11-26 16:43:16','2025-11-26 09:43:00','2025-11-26 09:43:00','2025-11-26 16:43:16'),(2,2,'in_app','service_hotel_update','Khách sạn đã được cập nhật','Thông tin khách sạn \'khách sạn đêm\' đã được cập nhật thành công.',1,'2025-11-26 16:46:29','2025-11-26 09:43:46','2025-11-26 09:43:46','2025-11-26 16:46:29'),(3,2,'in_app','service_hotel_new','Khách sạn mới đã được tạo','Khách sạn \'hfhfhffh\' đã được tạo thành công.',0,NULL,'2025-11-26 09:49:57','2025-11-26 09:49:57','2025-11-26 09:49:57'),(4,2,'in_app','service_hotel_update','Khách sạn đã được cập nhật','Thông tin khách sạn \'Khách sạn việt nam nam\' đã được cập nhật thành công.',0,NULL,'2025-11-26 09:54:14','2025-11-26 09:54:14','2025-11-26 09:54:14'),(5,2,'in_app','service_hotel_update','Khách sạn đã được cập nhật','Thông tin khách sạn \'Khách sạn việt nam \' đã được cập nhật thành công.',1,'2025-11-27 22:09:58','2025-11-26 09:57:58','2025-11-26 09:57:58','2025-11-27 22:09:57'),(6,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'123231\' thành công (Mã: BK19). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',1,'2025-11-27 21:56:59','2025-11-27 14:24:13','2025-11-27 14:24:13','2025-11-27 21:56:58'),(7,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'123231\' (Mã: BK19) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-11-27 14:24:17','2025-11-27 14:24:17','2025-11-27 14:24:17'),(8,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'khách sạn đêm\' thành công (Mã: BK20). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-11-27 14:59:41','2025-11-27 14:59:41','2025-11-27 14:59:41'),(9,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'khách sạn đêm\' (Mã: BK20) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',1,'2025-11-27 22:26:51','2025-11-27 14:59:45','2025-11-27 14:59:45','2025-11-27 22:26:50'),(10,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'khách sạn đêm\' (Mã: BK20) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-11-27 15:15:49','2025-11-27 15:15:49','2025-11-27 15:15:49'),(11,1,'in_app','service_hotel_booking','Đặt phòng đã bị hủy','Rất tiếc, đơn đặt phòng \'123231\' (Mã: BK19) của bạn đã bị hủy. Vui lòng liên hệ để biết thêm chi tiết.',0,NULL,'2025-11-27 15:16:46','2025-11-27 15:16:46','2025-11-27 15:16:46'),(12,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'21323123\' (Mã: BK17) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-11-27 15:29:20','2025-11-27 15:29:20','2025-11-27 15:29:20'),(13,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'21323123\' (Mã: BK16) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-11-27 15:29:33','2025-11-27 15:29:33','2025-11-27 15:29:33'),(14,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'Khách sạn việt nam \' (Mã: BK15) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-11-27 15:32:07','2025-11-27 15:32:07','2025-11-27 15:32:07'),(15,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'khách sạn đêm\' thành công (Mã: BK21). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-11-30 09:06:50','2025-11-30 09:06:50','2025-11-30 09:06:50'),(16,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'khách sạn đêm\' (Mã: BK21) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-11-30 09:06:54','2025-11-30 09:06:54','2025-11-30 09:06:54'),(17,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'khách sạn đêm\' thành công (Mã: BK22). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-11-30 09:08:50','2025-11-30 09:08:50','2025-11-30 09:08:50'),(18,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'khách sạn đêm\' (Mã: BK22) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-11-30 09:08:53','2025-11-30 09:08:53','2025-11-30 09:08:53'),(19,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'khách sạn đêm\' thành công (Mã: BK23). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-11-30 09:11:24','2025-11-30 09:11:24','2025-11-30 09:11:24'),(20,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'khách sạn đêm\' (Mã: BK23) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-11-30 09:11:27','2025-11-30 09:11:27','2025-11-30 09:11:27'),(21,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'khách sạn đêm\' (Mã: BK23) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-11-30 09:13:16','2025-11-30 09:13:16','2025-11-30 09:13:16'),(22,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'123231\' thành công (Mã: BK24). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-11-30 09:20:13','2025-11-30 09:20:13','2025-11-30 09:20:13'),(23,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'123231\' (Mã: BK24) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-11-30 09:20:17','2025-11-30 09:20:17','2025-11-30 09:20:17'),(24,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'123231\' (Mã: BK24) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-11-30 09:20:55','2025-11-30 09:20:55','2025-11-30 09:20:55'),(25,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'khách sạn đêm\' (Mã: BK22) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-11-30 09:30:44','2025-11-30 09:30:44','2025-11-30 09:30:44'),(26,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'khách sạn đêm\' (Mã: BK21) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-11-30 09:37:27','2025-11-30 09:37:27','2025-11-30 09:37:27'),(27,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'123231\' thành công (Mã: BK25). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-11-30 10:04:05','2025-11-30 10:04:05','2025-11-30 10:04:05'),(28,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'123231\' (Mã: BK25) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-11-30 10:04:08','2025-11-30 10:04:08','2025-11-30 10:04:08'),(29,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'123231\' (Mã: BK25) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-11-30 10:04:30','2025-11-30 10:04:30','2025-11-30 10:04:30'),(30,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'123231\' thành công (Mã: BK26). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-11-30 10:10:56','2025-11-30 10:10:56','2025-11-30 10:10:56'),(31,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'123231\' (Mã: BK26) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-11-30 10:11:00','2025-11-30 10:11:00','2025-11-30 10:11:00'),(32,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'123231\' (Mã: BK26) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-11-30 10:11:15','2025-11-30 10:11:15','2025-11-30 10:11:15'),(33,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'Khách sạn việt nam \' (Mã: BK14) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-11-30 10:18:34','2025-11-30 10:18:34','2025-11-30 10:18:34'),(34,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'Khách sạn việt nam \' (Mã: BK13) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-11-30 10:32:41','2025-11-30 10:32:41','2025-11-30 10:32:41'),(35,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'123231\' thành công (Mã: BK27). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-11-30 10:34:36','2025-11-30 10:34:36','2025-11-30 10:34:36'),(36,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'123231\' (Mã: BK27) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-11-30 10:34:39','2025-11-30 10:34:39','2025-11-30 10:34:39'),(37,1,'in_app','service_hotel_booking','Đặt phòng đã bị hủy','Rất tiếc, đơn đặt phòng \'123231\' (Mã: BK27) của bạn đã bị hủy. Vui lòng liên hệ để biết thêm chi tiết.',0,NULL,'2025-11-30 10:35:07','2025-11-30 10:35:07','2025-11-30 10:35:07'),(38,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'123231\' thành công (Mã: BK28). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-11-30 10:36:15','2025-11-30 10:36:15','2025-11-30 10:36:15'),(39,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'123231\' (Mã: BK28) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-11-30 10:36:18','2025-11-30 10:36:18','2025-11-30 10:36:18'),(40,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'123231\' (Mã: BK28) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-11-30 10:36:31','2025-11-30 10:36:31','2025-11-30 10:36:31'),(41,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'123231\' thành công (Mã: BK29). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-11-30 10:43:19','2025-11-30 10:43:19','2025-11-30 10:43:19'),(42,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'123231\' (Mã: BK29) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-11-30 10:43:23','2025-11-30 10:43:23','2025-11-30 10:43:23'),(43,1,'in_app','service_hotel_booking','Đặt phòng đã bị hủy','Rất tiếc, đơn đặt phòng \'123231\' (Mã: BK29) của bạn đã bị hủy. Vui lòng liên hệ để biết thêm chi tiết.',0,NULL,'2025-11-30 10:43:44','2025-11-30 10:43:44','2025-11-30 10:43:44'),(44,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'123231\' thành công (Mã: BK30). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-11-30 11:07:32','2025-11-30 11:07:32','2025-11-30 11:07:32'),(45,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'123231\' (Mã: BK30) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-11-30 11:07:35','2025-11-30 11:07:35','2025-11-30 11:07:35'),(46,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'123231\' (Mã: BK30) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-11-30 11:07:43','2025-11-30 11:07:43','2025-11-30 11:07:43'),(47,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'123231\' thành công (Mã: BK31). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-11-30 11:08:13','2025-11-30 11:08:13','2025-11-30 11:08:13'),(48,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'123231\' (Mã: BK31) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-11-30 11:08:16','2025-11-30 11:08:16','2025-11-30 11:08:16'),(49,1,'in_app','service_hotel_booking','Đặt phòng đã bị hủy','Rất tiếc, đơn đặt phòng \'123231\' (Mã: BK31) của bạn đã bị hủy. Vui lòng liên hệ để biết thêm chi tiết.',0,NULL,'2025-11-30 11:08:28','2025-11-30 11:08:28','2025-11-30 11:08:28'),(50,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'123231\' thành công (Mã: BK32). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-11-30 11:12:26','2025-11-30 11:12:26','2025-11-30 11:12:26'),(51,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'123231\' (Mã: BK32) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-11-30 11:12:30','2025-11-30 11:12:30','2025-11-30 11:12:30'),(52,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'123231\' thành công (Mã: BK33). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-11-30 11:12:44','2025-11-30 11:12:44','2025-11-30 11:12:44'),(53,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'123231\' (Mã: BK33) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-11-30 11:12:47','2025-11-30 11:12:47','2025-11-30 11:12:47'),(54,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'123231\' (Mã: BK33) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-11-30 11:13:14','2025-11-30 11:13:14','2025-11-30 11:13:14'),(55,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'123231\' (Mã: BK32) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-11-30 11:17:58','2025-11-30 11:17:58','2025-11-30 11:17:58'),(56,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'123231\' thành công (Mã: BK34). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-11-30 11:24:09','2025-11-30 11:24:09','2025-11-30 11:24:09'),(57,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'123231\' (Mã: BK34) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-11-30 11:24:13','2025-11-30 11:24:13','2025-11-30 11:24:13'),(58,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'123231\' thành công (Mã: BK35). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-11-30 11:24:29','2025-11-30 11:24:29','2025-11-30 11:24:29'),(59,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'123231\' (Mã: BK35) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-11-30 11:24:33','2025-11-30 11:24:33','2025-11-30 11:24:33'),(60,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'123231\' thành công (Mã: BK36). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-11-30 11:24:53','2025-11-30 11:24:53','2025-11-30 11:24:53'),(61,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'123231\' (Mã: BK36) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-11-30 11:24:56','2025-11-30 11:24:56','2025-11-30 11:24:56'),(62,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'123231\' thành công (Mã: BK37). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-11-30 11:25:07','2025-11-30 11:25:07','2025-11-30 11:25:07'),(63,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'123231\' (Mã: BK37) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-11-30 11:25:10','2025-11-30 11:25:10','2025-11-30 11:25:10'),(64,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'123231\' (Mã: BK37) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-11-30 11:25:20','2025-11-30 11:25:20','2025-11-30 11:25:20'),(65,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'123231\' (Mã: BK36) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-11-30 11:28:00','2025-11-30 11:28:00','2025-11-30 11:28:00'),(66,1,'in_app','service_hotel_booking','Đặt phòng đã bị hủy','Rất tiếc, đơn đặt phòng \'123231\' (Mã: BK35) của bạn đã bị hủy. Vui lòng liên hệ để biết thêm chi tiết.',0,NULL,'2025-11-30 11:28:12','2025-11-30 11:28:12','2025-11-30 11:28:12'),(67,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'123231\' thành công (Mã: BK38). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-11-30 11:37:51','2025-11-30 11:37:51','2025-11-30 11:37:51'),(68,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'123231\' (Mã: BK38) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-11-30 11:37:54','2025-11-30 11:37:54','2025-11-30 11:37:54'),(69,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'123231\' (Mã: BK38) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',1,'2025-11-30 18:41:41','2025-11-30 11:38:05','2025-11-30 11:38:05','2025-11-30 18:41:40'),(70,2,'in_app','service_hotel_new','Khách sạn mới đã được tạo','Khách sạn \'khách sạn viop\' đã được tạo thành công.',0,NULL,'2025-12-01 03:01:19','2025-12-01 03:01:19','2025-12-01 03:01:19'),(71,2,'in_app','service_hotel_new','Khách sạn mới đã được tạo','Khách sạn \'34324\' đã được tạo thành công.',0,NULL,'2025-12-01 03:10:10','2025-12-01 03:10:10','2025-12-01 03:10:10'),(72,2,'in_app','service_hotel_update','Khách sạn đã được cập nhật','Thông tin khách sạn \'34324\' đã được cập nhật thành công.',0,NULL,'2025-12-01 03:11:01','2025-12-01 03:11:01','2025-12-01 03:11:01'),(73,2,'in_app','service_hotel_update','Khách sạn đã được cập nhật','Thông tin khách sạn \'34324\' đã được cập nhật thành công.',0,NULL,'2025-12-01 03:23:50','2025-12-01 03:23:50','2025-12-01 03:23:50'),(74,2,'in_app','service_hotel_update','Khách sạn đã được cập nhật','Thông tin khách sạn \'34324\' đã được cập nhật thành công.',0,NULL,'2025-12-01 03:24:42','2025-12-01 03:24:42','2025-12-01 03:24:42'),(75,2,'in_app','service_hotel_update','Khách sạn đã được cập nhật','Thông tin khách sạn \'34324\' đã được cập nhật thành công.',0,NULL,'2025-12-01 03:26:29','2025-12-01 03:26:29','2025-12-01 03:26:29'),(76,2,'in_app','service_hotel_update','Khách sạn đã được cập nhật','Thông tin khách sạn \'Khách sạn việt nam \' đã được cập nhật thành công.',0,NULL,'2025-12-01 03:28:00','2025-12-01 03:28:00','2025-12-01 03:28:00'),(77,2,'in_app','service_hotel_update','Khách sạn đã được cập nhật','Thông tin khách sạn \'Khách sạn việt nam \' đã được cập nhật thành công.',0,NULL,'2025-12-01 03:28:15','2025-12-01 03:28:15','2025-12-01 03:28:15'),(78,2,'in_app','service_hotel_new','Khách sạn mới đã được tạo','Khách sạn \'khách sạn đà nẵng \' đã được tạo thành công.',0,NULL,'2025-12-01 12:56:23','2025-12-01 12:56:23','2025-12-01 12:56:23'),(79,2,'in_app','service_hotel_new','Khách sạn mới đã được tạo','Khách sạn \'khách sạn hà nội\' đã được tạo thành công.',0,NULL,'2025-12-01 13:13:12','2025-12-01 13:13:12','2025-12-01 13:13:12'),(80,2,'in_app','service_hotel_update','Khách sạn đã được cập nhật','Thông tin khách sạn \'khách sạn hà nội\' đã được cập nhật thành công.',0,NULL,'2025-12-01 13:13:57','2025-12-01 13:13:57','2025-12-01 13:13:57'),(81,2,'in_app','service_hotel_new','Khách sạn mới đã được tạo','Khách sạn \'khách sạn víp đà nẵng\' đã được tạo thành công.',0,NULL,'2025-12-01 13:22:22','2025-12-01 13:22:22','2025-12-01 13:22:22'),(82,2,'in_app','service_hotel_update','Khách sạn đã được cập nhật','Thông tin khách sạn \'khách sạn víp đà nẵng\' đã được cập nhật thành công.',0,NULL,'2025-12-01 13:24:28','2025-12-01 13:24:28','2025-12-01 13:24:28'),(83,2,'in_app','service_hotel_new','Khách sạn mới đã được tạo','Khách sạn \'23\' đã được tạo thành công.',0,NULL,'2025-12-01 14:02:23','2025-12-01 14:02:23','2025-12-01 14:02:23'),(84,2,'in_app','service_hotel_update','Khách sạn đã được cập nhật','Thông tin khách sạn \'khách sạn bà rịa\' đã được cập nhật thành công.',0,NULL,'2025-12-01 14:03:01','2025-12-01 14:03:01','2025-12-01 14:03:01'),(85,2,'in_app','service_hotel_update','Khách sạn đã được cập nhật','Thông tin khách sạn \'khách sạn bà rịa\' đã được cập nhật thành công.',0,NULL,'2025-12-01 14:07:10','2025-12-01 14:07:10','2025-12-01 14:07:10'),(86,2,'in_app','service_hotel_new','Khách sạn mới đã được tạo','Khách sạn \'3123\' đã được tạo thành công.',0,NULL,'2025-12-02 08:01:38','2025-12-02 08:01:38','2025-12-02 08:01:38'),(87,2,'in_app','service_hotel_update','Khách sạn đã được cập nhật','Thông tin khách sạn \'3123\' đã được cập nhật thành công.',0,NULL,'2025-12-02 08:02:30','2025-12-02 08:02:30','2025-12-02 08:02:30'),(88,2,'in_app','service_hotel_new','Khách sạn mới đã được tạo','Khách sạn \'213\' đã được tạo thành công.',0,NULL,'2025-12-05 07:59:24','2025-12-05 07:59:24','2025-12-05 07:59:24'),(89,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'123231\' (Mã: BK34) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-12-08 07:22:33','2025-12-08 07:22:33','2025-12-08 07:22:33'),(90,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'khách sạn bà rịa\' thành công (Mã: BK39). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-12-08 07:47:39','2025-12-08 07:47:39','2025-12-08 07:47:39'),(91,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'khách sạn bà rịa\' (Mã: BK39) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-12-08 07:47:42','2025-12-08 07:47:42','2025-12-08 07:47:42'),(92,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'nhà hàng siêu su\' thành công (Mã: RBK1). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-12-09 04:22:06','2025-12-09 04:22:06','2025-12-09 04:22:06'),(93,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'nhà hàng siêu su\' (Mã: RBK1) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-12-09 04:22:10','2025-12-09 04:22:10','2025-12-09 04:22:10'),(94,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'nhà hàng siêu su\' thành công (Mã: RBK2). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-12-09 04:25:00','2025-12-09 04:25:00','2025-12-09 04:25:00'),(95,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'nhà hàng siêu su\' (Mã: RBK2) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-12-09 04:25:03','2025-12-09 04:25:03','2025-12-09 04:25:03'),(96,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'nhà hàng siêu su\' thành công (Mã: RBK3). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-12-09 05:12:35','2025-12-09 05:12:35','2025-12-09 05:12:35'),(97,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'nhà hàng siêu su\' (Mã: RBK3) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-12-09 05:12:39','2025-12-09 05:12:39','2025-12-09 05:12:39'),(98,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'Tour du lịch cảnh hồ chí minh\' thành công (Mã: TBK1). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-12-09 14:18:18','2025-12-09 14:18:18','2025-12-09 14:18:18'),(99,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'Tour du lịch cảnh hồ chí minh\' (Mã: TBK1) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-12-09 14:18:18','2025-12-09 14:18:18','2025-12-09 14:18:18'),(100,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'Tour du lịch cảnh hồ chí minh\' thành công (Mã: TBK2). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-12-09 14:19:53','2025-12-09 14:19:53','2025-12-09 14:19:53'),(101,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'Tour du lịch cảnh hồ chí minh\' (Mã: TBK2) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-12-09 14:19:53','2025-12-09 14:19:53','2025-12-09 14:19:53'),(102,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'Tour du lịch cảnh hồ chí minh\' thành công (Mã: TBK3). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-12-09 15:06:24','2025-12-09 15:06:24','2025-12-09 15:06:24'),(103,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'Tour du lịch cảnh hồ chí minh\' (Mã: TBK3) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-12-09 15:06:24','2025-12-09 15:06:24','2025-12-09 15:06:24'),(104,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'Tour du lịch cảnh hồ chí minh\' (Mã: TBK3) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-12-09 15:20:59','2025-12-09 15:20:59','2025-12-09 15:20:59'),(105,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'Tour du lịch cảnh hồ chí minh\' (Mã: TBK3) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-12-09 15:27:35','2025-12-09 15:27:35','2025-12-09 15:27:35'),(106,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'Tour du lịch cảnh hồ chí minh\' (Mã: TBK2) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-12-09 15:27:44','2025-12-09 15:27:44','2025-12-09 15:27:44'),(107,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'Tour du lịch cảnh hồ chí minh\' (Mã: TBK1) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-12-09 15:34:31','2025-12-09 15:34:31','2025-12-09 15:34:31'),(108,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'Tour du lịch cảnh hồ chí minh\' thành công (Mã: TBK4). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-12-09 15:35:01','2025-12-09 15:35:01','2025-12-09 15:35:01'),(109,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'Tour du lịch cảnh hồ chí minh\' (Mã: TBK4) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-12-09 15:35:01','2025-12-09 15:35:01','2025-12-09 15:35:01'),(110,1,'in_app','service_attraction_booking','Đặt điểm tham quan thành công','Bạn đã đặt \'bảo tàng việt nam đà nẵng\' thành công (Mã: ATB1). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-12-10 12:48:26','2025-12-10 12:48:26','2025-12-10 12:48:26'),(111,2,'in_app','service_attraction_booking','Đơn đặt điểm tham quan mới','Có đơn đặt mới cho \'bảo tàng việt nam đà nẵng\' (Mã: ATB1) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-12-10 12:48:30','2025-12-10 12:48:30','2025-12-10 12:48:30'),(112,1,'in_app','service_attraction_booking','Đặt điểm tham quan đã được xác nhận','Đơn đặt \'bảo tàng việt nam đà nẵng\' (Mã: ATB1) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-12-10 13:14:46','2025-12-10 13:14:46','2025-12-10 13:14:46'),(113,1,'in_app','service_attraction_booking','Đặt điểm tham quan thành công','Bạn đã đặt \'bảo tàng việt nam đà nẵng\' thành công (Mã: ATB2). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-12-10 13:57:51','2025-12-10 13:57:51','2025-12-10 13:57:51'),(114,2,'in_app','service_attraction_booking','Đơn đặt điểm tham quan mới','Có đơn đặt mới cho \'bảo tàng việt nam đà nẵng\' (Mã: ATB2) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-12-10 13:57:55','2025-12-10 13:57:55','2025-12-10 13:57:55'),(115,1,'in_app','service_tour_booking','Đặt tour thành công','Bạn đã đặt tour \'Tour du lịch cảnh hồ chí minh\' thành công (Mã: TBK5). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-12-10 13:58:46','2025-12-10 13:58:46','2025-12-10 13:58:46'),(116,2,'in_app','service_tour_booking','Đơn đặt tour mới','Có đơn đặt tour mới cho \'Tour du lịch cảnh hồ chí minh\' (Mã: TBK5) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-12-10 13:58:46','2025-12-10 13:58:46','2025-12-10 13:58:46'),(117,1,'in_app','service_restaurant_booking','Đặt nhà hàng thành công','Bạn đã đặt bàn tại \'nhà hàng siêu su\' thành công (Mã: RBK4). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-12-10 13:59:12','2025-12-10 13:59:12','2025-12-10 13:59:12'),(118,2,'in_app','service_restaurant_booking','Đơn đặt bàn mới','Có đơn đặt bàn mới tại \'nhà hàng siêu su\' (Mã: RBK4) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-12-10 13:59:15','2025-12-10 13:59:15','2025-12-10 13:59:15'),(119,1,'in_app','service_restaurant_booking','Đặt bàn đã được xác nhận','Đơn đặt bàn tại \'nhà hàng siêu su\' (Mã: RBK4) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-12-10 14:00:46','2025-12-10 14:00:46','2025-12-10 14:00:46'),(120,1,'in_app','service_tour_booking','Đặt tour đã được xác nhận','Đơn đặt tour \'Tour du lịch cảnh hồ chí minh\' (Mã: TBK5) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-12-10 14:14:56','2025-12-10 14:14:56','2025-12-10 14:14:56'),(121,1,'in_app','service_tour_booking','Đặt tour đã được xác nhận','Đơn đặt tour \'Tour du lịch cảnh hồ chí minh\' (Mã: TBK4) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-12-10 14:15:22','2025-12-10 14:15:22','2025-12-10 14:15:22'),(122,2,'in_app','service_tour_update','Tour đã được cập nhật','Thông tin tour \'tour hạ long vip\' đã được cập nhật thành công.',0,NULL,'2025-12-12 11:52:36','2025-12-12 11:52:36','2025-12-12 11:52:36'),(123,2,'in_app','service_attraction_update','Điểm tham quan đã được cập nhật','Thông tin điểm tham quan \'bảo tàng\' đã được cập nhật thành công.',0,NULL,'2025-12-12 11:54:00','2025-12-12 11:54:00','2025-12-12 11:54:00'),(124,2,'in_app','service_tour_update','Tour đã được cập nhật','Thông tin tour \'tour hạ long vip\' đã được cập nhật thành công.',0,NULL,'2025-12-12 12:42:30','2025-12-12 12:42:30','2025-12-12 12:42:30'),(125,2,'in_app','service_tour_new','Tour mới đã được tạo','Tour \'trest tour\' đã được tạo thành công.',0,NULL,'2025-12-12 12:58:26','2025-12-12 12:58:26','2025-12-12 12:58:26'),(126,2,'in_app','service_tour_new','Tour mới đã được tạo','Tour \'1231\' đã được tạo thành công.',0,NULL,'2025-12-12 13:39:10','2025-12-12 13:39:10','2025-12-12 13:39:10'),(127,2,'in_app','service_tour_new','Tour mới đã được tạo','Tour \'tỏu sfap\' đã được tạo thành công.',0,NULL,'2025-12-12 13:55:10','2025-12-12 13:55:10','2025-12-12 13:55:10'),(128,2,'in_app','service_tour_new','Tour mới đã được tạo','Tour \'tour vip \' đã được tạo thành công.',0,NULL,'2025-12-12 14:03:55','2025-12-12 14:03:55','2025-12-12 14:03:55'),(129,1,'in_app','service_hotel_booking','Đặt phòng thành công','Bạn đã đặt phòng \'3123\' thành công (Mã: BK40). Vui lòng đợi 1-2 tiếng để đội ngũ liên hệ xác nhận.',0,NULL,'2025-12-12 15:28:29','2025-12-12 15:28:29','2025-12-12 15:28:29'),(130,2,'in_app','service_hotel_booking','Đơn đặt phòng mới','Có đơn đặt phòng mới cho \'3123\' (Mã: BK40) từ khách hàng congdeptrai. Vui lòng xác nhận đơn hàng.',0,NULL,'2025-12-12 15:28:33','2025-12-12 15:28:33','2025-12-12 15:28:33'),(131,1,'in_app','service_hotel_booking','Đặt phòng đã được xác nhận','Đơn đặt phòng \'3123\' (Mã: BK40) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!',0,NULL,'2025-12-12 15:28:53','2025-12-12 15:28:53','2025-12-12 15:28:53');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `points`
--

DROP TABLE IF EXISTS `points`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `points` (
  `point_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `points` int NOT NULL,
  `reason` varchar(255) NOT NULL,
  `related_id` int DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`point_id`),
  KEY `fk_points_user` (`user_id`),
  CONSTRAINT `fk_points_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `points`
--

LOCK TABLES `points` WRITE;
/*!40000 ALTER TABLE `points` DISABLE KEYS */;
INSERT INTO `points` VALUES (1,1,50,'Booking Khách sạn thành công',40,'2025-12-12 15:28:53');
/*!40000 ALTER TABLE `points` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `provider_reviews`
--

DROP TABLE IF EXISTS `provider_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `provider_reviews` (
  `review_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `provider_id` int NOT NULL,
  `rating` int NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `content` text NOT NULL,
  `image_urls` text,
  `likes_count` int NOT NULL DEFAULT '0',
  `reply_count` int NOT NULL DEFAULT '0',
  `review_status` enum('approved','rejected') NOT NULL DEFAULT 'approved',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`review_id`),
  KEY `fk_provider_review_user` (`user_id`),
  KEY `fk_provider_review_provider` (`provider_id`),
  CONSTRAINT `fk_provider_review_provider` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`provider_id`),
  CONSTRAINT `fk_provider_review_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `provider_reviews_chk_1` CHECK ((`rating` between 1 and 5))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `provider_reviews`
--

LOCK TABLES `provider_reviews` WRITE;
/*!40000 ALTER TABLE `provider_reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `provider_reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `providers`
--

DROP TABLE IF EXISTS `providers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `providers` (
  `provider_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `company_name` varchar(255) NOT NULL,
  `tax_code` varchar(100) DEFAULT NULL,
  `address` varchar(512) DEFAULT NULL,
  `contact_email` varchar(255) DEFAULT NULL,
  `contact_phone` varchar(20) DEFAULT NULL,
  `bank_account_number` varchar(100) DEFAULT NULL,
  `bank_name` varchar(255) DEFAULT NULL,
  `logo_url` varchar(512) DEFAULT NULL,
  `provider_description` text,
  `rating_overall` decimal(3,2) NOT NULL DEFAULT '0.00',
  `provider_status` enum('approved','pending','rejected','suspended') NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`provider_id`),
  KEY `fk_providers_user` (`user_id`),
  CONSTRAINT `fk_providers_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `providers`
--

LOCK TABLES `providers` WRITE;
/*!40000 ALTER TABLE `providers` DISABLE KEYS */;
INSERT INTO `providers` VALUES (1,2,'tripfinity','123','1231231231','tripfinity@gmail.com','1231232213','12312321312','1213123123','https://res.cloudinary.com/tripfinity-img/image/upload/v1761624260/assets/ea7a0859-a0d3-424e-87cc-0ffe82c0ccb2.png','123213123',0.00,'pending','2025-10-28 04:04:17','2025-10-28 04:04:19'),(2,7,'test shop','2002','20020','nguyenmin4869@gmail.com','098766789','213123123','12312','https://res.cloudinary.com/tripfinity-img/image/upload/v1764924392/assets/13dcbaf3-576e-4e58-82f9-f5964582fb14.png','123123213',0.00,'pending','2025-12-05 08:46:29','2025-12-05 08:46:31');
/*!40000 ALTER TABLE `providers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `restaurant_bookings`
--

DROP TABLE IF EXISTS `restaurant_bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurant_bookings` (
  `booking_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `restaurant_id` int NOT NULL,
  `booking_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `reservation_date` date DEFAULT NULL COMMENT 'Ngày đặt bàn',
  `reservation_time` varchar(255) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `num_adults` int NOT NULL DEFAULT '1',
  `special_requests` text COMMENT 'Yêu cầu đặc biệt (ghế gần cửa sổ, sinh nhật, etc)',
  `total_price` decimal(12,2) NOT NULL,
  `deposit_amount` decimal(12,2) DEFAULT NULL COMMENT 'Tiền đặt cọc',
  `currency_code` varchar(3) NOT NULL,
  `booking_status` enum('cancelled','completed','confirmed','pending','refunded') NOT NULL,
  `e_ticket_url` varchar(512) DEFAULT NULL,
  `qr_code_data` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `provider_id` int DEFAULT NULL,
  `channel` varchar(100) DEFAULT NULL,
  `hold_until` datetime DEFAULT NULL,
  `provider_seen` tinyint(1) NOT NULL DEFAULT '0',
  `provider_notes` text,
  `provider_confirmed` int NOT NULL,
  `provider_confirmed_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`booking_id`),
  KEY `fk_rest_booking_user` (`user_id`),
  KEY `fk_rest_booking_rest` (`restaurant_id`),
  KEY `idx_rest_bookings_provider` (`provider_id`),
  KEY `idx_rest_bookings_status` (`booking_status`),
  KEY `idx_rest_booking_reservation_date` (`reservation_date`),
  CONSTRAINT `fk_rest_booking_provider` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`provider_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_rest_booking_rest` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`restaurant_id`),
  CONSTRAINT `fk_rest_booking_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `restaurant_bookings`
--

LOCK TABLES `restaurant_bookings` WRITE;
/*!40000 ALTER TABLE `restaurant_bookings` DISABLE KEYS */;
INSERT INTO `restaurant_bookings` VALUES (1,1,2,'2025-12-09 04:22:06',NULL,NULL,'2025-12-10',NULL,3,NULL,300000.00,NULL,'VND','cancelled',NULL,NULL,'2025-12-09 04:22:06','2025-12-09 05:14:38',1,NULL,NULL,0,'people=3',2,'2025-12-09 05:14:38.418578'),(2,1,2,'2025-12-09 04:25:00',NULL,NULL,'2025-12-10',NULL,2,NULL,200000.00,NULL,'VND','cancelled',NULL,NULL,'2025-12-09 04:25:00','2025-12-09 05:14:53',1,'mobile_app',NULL,0,'people=2',2,'2025-12-09 05:14:52.528339'),(3,1,2,'2025-12-09 05:12:35','2025-12-12','04:00:00',NULL,NULL,3,NULL,300000.00,NULL,'VND','confirmed',NULL,NULL,'2025-12-09 05:12:35','2025-12-09 05:13:41',1,NULL,NULL,0,'people=3',1,'2025-12-09 05:13:41.381535'),(4,1,2,'2025-12-10 13:59:12','2025-12-11','18:00:00',NULL,NULL,2,NULL,200000.00,NULL,'VND','confirmed',NULL,NULL,'2025-12-10 13:59:12','2025-12-10 14:00:46',1,NULL,NULL,0,'people=2',1,'2025-12-10 14:00:45.516174');
/*!40000 ALTER TABLE `restaurant_bookings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `restaurant_payments`
--

DROP TABLE IF EXISTS `restaurant_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurant_payments` (
  `payment_id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `user_id` int NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `currency_code` varchar(3) NOT NULL,
  `payment_method` enum('counter','mastercard','momo','other','paypal','visa','vnpay','zalopay') NOT NULL,
  `transaction_id` varchar(255) NOT NULL,
  `payment_status` enum('failed','pending','refunded','success') NOT NULL,
  `payment_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`payment_id`),
  UNIQUE KEY `transaction_id` (`transaction_id`),
  KEY `fk_rest_pay_booking` (`booking_id`),
  KEY `fk_rest_pay_user` (`user_id`),
  CONSTRAINT `fk_rest_pay_booking` FOREIGN KEY (`booking_id`) REFERENCES `restaurant_bookings` (`booking_id`),
  CONSTRAINT `fk_rest_pay_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `restaurant_payments`
--

LOCK TABLES `restaurant_payments` WRITE;
/*!40000 ALTER TABLE `restaurant_payments` DISABLE KEYS */;
INSERT INTO `restaurant_payments` VALUES (1,1,1,300000.00,'VND','counter','REST-1-1765254126410','pending','2025-12-09 04:22:06','2025-12-09 04:22:06','2025-12-09 04:22:06'),(2,2,1,200000.00,'VND','zalopay','REST-2-1765254299989','success','2025-12-09 04:25:00','2025-12-09 04:25:00','2025-12-09 04:25:00'),(3,3,1,300000.00,'VND','counter','REST-3-1765257154580','pending','2025-12-09 05:12:35','2025-12-09 05:12:35','2025-12-09 05:12:35'),(4,4,1,200000.00,'VND','counter','REST-4-1765375152019','pending','2025-12-10 13:59:12','2025-12-10 13:59:12','2025-12-10 13:59:12');
/*!40000 ALTER TABLE `restaurant_payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `restaurant_rating_summaries`
--

DROP TABLE IF EXISTS `restaurant_rating_summaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurant_rating_summaries` (
  `restaurant_id` int NOT NULL,
  `avg_rating` decimal(3,2) NOT NULL DEFAULT '0.00',
  `total_reviews` int NOT NULL DEFAULT '0',
  `count_1` int NOT NULL DEFAULT '0',
  `count_2` int NOT NULL DEFAULT '0',
  `count_3` int NOT NULL DEFAULT '0',
  `count_4` int NOT NULL DEFAULT '0',
  `count_5` int NOT NULL DEFAULT '0',
  `avg_quality` decimal(3,2) DEFAULT NULL,
  `avg_service` decimal(3,2) DEFAULT NULL,
  `avg_price` decimal(3,2) DEFAULT NULL,
  `avg_location` decimal(3,2) DEFAULT NULL,
  `avg_ambience` decimal(3,2) DEFAULT NULL,
  PRIMARY KEY (`restaurant_id`),
  CONSTRAINT `fk_rest_rating` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`restaurant_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `restaurant_rating_summaries`
--

LOCK TABLES `restaurant_rating_summaries` WRITE;
/*!40000 ALTER TABLE `restaurant_rating_summaries` DISABLE KEYS */;
/*!40000 ALTER TABLE `restaurant_rating_summaries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `restaurant_review_aspects`
--

DROP TABLE IF EXISTS `restaurant_review_aspects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurant_review_aspects` (
  `review_id` int NOT NULL,
  `quality` int NOT NULL,
  `service` int NOT NULL,
  `price` int NOT NULL,
  `location` int NOT NULL,
  `ambience` int NOT NULL,
  PRIMARY KEY (`review_id`),
  CONSTRAINT `fk_rest_aspects_review` FOREIGN KEY (`review_id`) REFERENCES `restaurant_reviews` (`review_id`) ON DELETE CASCADE,
  CONSTRAINT `restaurant_review_aspects_chk_1` CHECK ((`quality` between 1 and 5)),
  CONSTRAINT `restaurant_review_aspects_chk_2` CHECK ((`service` between 1 and 5)),
  CONSTRAINT `restaurant_review_aspects_chk_3` CHECK ((`price` between 1 and 5)),
  CONSTRAINT `restaurant_review_aspects_chk_4` CHECK ((`location` between 1 and 5)),
  CONSTRAINT `restaurant_review_aspects_chk_5` CHECK ((`ambience` between 1 and 5))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `restaurant_review_aspects`
--

LOCK TABLES `restaurant_review_aspects` WRITE;
/*!40000 ALTER TABLE `restaurant_review_aspects` DISABLE KEYS */;
INSERT INTO `restaurant_review_aspects` VALUES (1,3,3,3,3,3),(2,2,2,2,2,2),(3,1,1,1,1,1);
/*!40000 ALTER TABLE `restaurant_review_aspects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `restaurant_reviews`
--

DROP TABLE IF EXISTS `restaurant_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurant_reviews` (
  `review_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `restaurant_id` int NOT NULL,
  `rating` int NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `content` text NOT NULL,
  `image_urls` text,
  `likes_count` int NOT NULL DEFAULT '0',
  `reply_count` int NOT NULL DEFAULT '0',
  `review_status` enum('approved','rejected') NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`review_id`),
  KEY `fk_rest_review_user` (`user_id`),
  KEY `fk_rest_review_rest` (`restaurant_id`),
  CONSTRAINT `fk_rest_review_rest` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`restaurant_id`),
  CONSTRAINT `fk_rest_review_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `restaurant_reviews_chk_1` CHECK ((`rating` between 1 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `restaurant_reviews`
--

LOCK TABLES `restaurant_reviews` WRITE;
/*!40000 ALTER TABLE `restaurant_reviews` DISABLE KEYS */;
INSERT INTO `restaurant_reviews` VALUES (1,1,2,4,'132','123123',NULL,0,0,'approved','2025-12-08 10:31:16','2025-12-08 10:31:16'),(2,1,2,3,'12312322','13123123','https://res.cloudinary.com/tripfinity-img/image/upload/v1765191539/assets/2767ce27-f43c-4c6d-86d6-1410eaf3e0df.jpg',0,0,'approved','2025-12-08 10:58:59','2025-12-08 10:58:59'),(3,1,2,1,'324','234234','https://res.cloudinary.com/tripfinity-img/image/upload/v1765191956/assets/106a1abb-fe96-4f5d-b932-4a2629e9c3dd.jpg',0,0,'approved','2025-12-08 11:05:55','2025-12-08 11:05:55');
/*!40000 ALTER TABLE `restaurant_reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `restaurants`
--

DROP TABLE IF EXISTS `restaurants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants` (
  `restaurant_id` int NOT NULL AUTO_INCREMENT,
  `provider_id` int NOT NULL,
  `area_id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `service_description` text,
  `location` varchar(255) DEFAULT NULL COMMENT 'Tỉnh/thành phố (tên)',
  `address` varchar(255) DEFAULT NULL COMMENT 'Địa chỉ đầy đủ',
  `latitude` decimal(10,8) DEFAULT NULL COMMENT 'Latitude coordinate',
  `longitude` decimal(11,8) DEFAULT NULL COMMENT 'Longitude coordinate',
  `phone` varchar(20) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `price` decimal(12,2) NOT NULL COMMENT 'Giá trung bình 1 người',
  `currency_code` varchar(3) NOT NULL DEFAULT 'VND',
  `price_level` enum('cheap','expensive','luxury','moderate') DEFAULT NULL,
  `capacity` int DEFAULT NULL COMMENT 'Số chỗ ngồi tối đa',
  `min_participants` int DEFAULT NULL COMMENT 'Số người tối thiểu (group booking)',
  `max_participants` int DEFAULT NULL COMMENT 'Số người tối đa (group booking)',
  `thumbnail_url` varchar(512) DEFAULT NULL,
  `image_urls` json DEFAULT NULL COMMENT 'Array of image URLs (JSON)',
  `badges` varchar(255) DEFAULT NULL,
  `restaurant_status` enum('archived','disabled','published') NOT NULL,
  `visibility` enum('private_','public_') NOT NULL,
  `is_featured` tinyint(1) NOT NULL DEFAULT '0',
  `cuisines_json` json DEFAULT NULL COMMENT 'Array of cuisine types: ["vietnamese","chinese","japanese","korean","italian","french","thai","indian","american","mexican","seafood","vegetarian","fusion","bbq","hotpot"]',
  `services_json` json DEFAULT NULL COMMENT 'Array: ["dine_in","takeaway","delivery","reservation","private_room","buffet","outdoor_seating","live_music","wifi","parking"]',
  `diets_json` json DEFAULT NULL COMMENT 'Array: ["vegetarian","vegan","halal","kosher","gluten_free","dairy_free","nut_free","low_carb","keto"]',
  `opening_hours_json` json DEFAULT NULL COMMENT 'Object: {"monday":"10:00-22:00","tuesday":"10:00-22:00",...}',
  `menu_highlights_json` json DEFAULT NULL COMMENT 'Array of signature dishes',
  `ambiance_tags_json` json DEFAULT NULL COMMENT 'Array: ["romantic","family_friendly","business","casual","formal","cozy","modern","traditional","rooftop","beachfront"]',
  `payment_methods_json` json DEFAULT NULL COMMENT 'Array: ["cash","credit_card","debit_card","momo","zalopay","vnpay"]',
  `policies_text` text COMMENT 'Chính sách: dress code, reservation, cancellation',
  `slug` varchar(255) DEFAULT NULL,
  `seo_title` varchar(255) DEFAULT NULL,
  `seo_description` varchar(512) DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`restaurant_id`),
  UNIQUE KEY `uq_restaurants_slug` (`slug`),
  KEY `fk_restaurants_area` (`area_id`),
  KEY `idx_restaurants_provider` (`provider_id`),
  KEY `idx_restaurants_status` (`restaurant_status`),
  KEY `idx_restaurants_price_level` (`price_level`),
  KEY `idx_restaurants_featured` (`is_featured`),
  CONSTRAINT `fk_restaurants_area` FOREIGN KEY (`area_id`) REFERENCES `areas` (`area_id`),
  CONSTRAINT `fk_restaurants_provider` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`provider_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `restaurants`
--

LOCK TABLES `restaurants` WRITE;
/*!40000 ALTER TABLE `restaurants` DISABLE KEYS */;
INSERT INTO `restaurants` VALUES (1,1,58,'nhà hàng siêu ngoi',NULL,'TP. Hồ Chí Minh','Đường số 123, Khu phố 35, Phường Phước Long, Thành phố Thủ Đức, Thành phố Hồ Chí Minh, 71210, Việt Nam',10.81673820,106.76581390,'13',NULL,'2025-12-05','2025-12-12',1321.00,'VND','cheap',12,1,1,'https://res.cloudinary.com/tripfinity-img/image/upload/v1764937114/assets/451e0e0d-bdee-4782-ad4c-04c6d9066239.png','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1764937117/assets/a4a7d240-1351-4001-9a93-1e5c68027961.png\"]','[\"Bestseller\"]','published','public_',1,'[\"fusion\", \"bbq\"]','[\"private_room\"]','[\"halal\", \"dairy_free\"]','{\"friday\": \"\", \"monday\": \"Đóng cửa\", \"sunday\": \"\", \"tuesday\": \"\", \"saturday\": \"19:17-17:00\", \"thursday\": \"Đóng cửa\", \"wednesday\": \"\"}','[\"2132131232\"]','[\"modern\", \"traditional\"]','[\"cash\"]','43','nha-hang-127189940','nhà hàng432','423',NULL,'2025-12-05 12:18:37','2025-12-05 12:37:47'),(2,1,15,'nhà hàng siêu su','123123','Đà Nẵng','123, 132, Đường Cô Giang, Phước Ninh, Phường Hải Châu, Thành phố Đà Nẵng, 02363, Việt Nam',16.06151530,108.22146780,NULL,NULL,'2025-12-05','2025-12-13',100000.00,'VND','cheap',12,2,21,'https://res.cloudinary.com/tripfinity-img/image/upload/v1764938242/assets/c3d3b9f6-e01b-4f42-b67e-77915e970457.jpg','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1764938243/assets/c4757532-7fee-4ca3-8585-b5bad590ae44.jpg\"]','[\"Bestseller\"]','published','public_',1,'[\"fusion\"]','[\"dine_in\"]','[\"vegetarian\"]','{\"friday\": \"\", \"monday\": \"Đóng cửa\", \"sunday\": \"\", \"tuesday\": \"19:36-17:00\", \"saturday\": \"\", \"thursday\": \"\", \"wednesday\": \"12:21-17:00\"}','[\"213\"]','[\"modern\"]','[\"zalopay\"]','213','nha-hang-sieu-su-668513163','nhà hàng siêu su','213',NULL,'2025-12-05 12:37:23','2025-12-09 04:21:13');
/*!40000 ALTER TABLE `restaurants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `review_likes`
--

DROP TABLE IF EXISTS `review_likes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `review_likes` (
  `like_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `review_type` varchar(20) NOT NULL,
  `review_id` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`like_id`),
  UNIQUE KEY `unique_review_like` (`user_id`,`review_type`,`review_id`),
  CONSTRAINT `fk_review_like_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `review_likes`
--

LOCK TABLES `review_likes` WRITE;
/*!40000 ALTER TABLE `review_likes` DISABLE KEYS */;
INSERT INTO `review_likes` VALUES (3,1,'hotel',4,'2025-11-22 09:28:58'),(15,1,'hotel',5,'2025-11-22 09:58:57'),(17,2,'hotel',4,'2025-11-22 11:24:17'),(18,2,'hotel',8,'2025-11-22 11:54:27'),(19,2,'hotel',7,'2025-11-22 12:31:04'),(20,2,'hotel',6,'2025-11-22 12:31:05'),(21,2,'hotel',5,'2025-11-22 12:31:07'),(22,2,'restaurant',3,'2025-12-08 12:46:20');
/*!40000 ALTER TABLE `review_likes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `review_replies`
--

DROP TABLE IF EXISTS `review_replies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `review_replies` (
  `reply_id` int NOT NULL AUTO_INCREMENT,
  `review_type` enum('attraction','hotel','provider','restaurant','tour') NOT NULL,
  `review_id` int NOT NULL,
  `replier_id` int NOT NULL,
  `content` text NOT NULL,
  `is_public` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_provider` int NOT NULL,
  PRIMARY KEY (`reply_id`),
  KEY `fk_reply_replier` (`replier_id`),
  CONSTRAINT `fk_reply_replier` FOREIGN KEY (`replier_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `review_replies`
--

LOCK TABLES `review_replies` WRITE;
/*!40000 ALTER TABLE `review_replies` DISABLE KEYS */;
INSERT INTO `review_replies` VALUES (2,'hotel',6,2,'áhkdfgkhjasdhkjasdfhkjasdfkhjasdfasdf',1,'2025-11-22 11:22:43','2025-11-22 11:22:43',1),(3,'hotel',6,2,'sdffsdfsd',1,'2025-11-22 11:43:55','2025-11-22 11:43:55',1),(4,'hotel',8,2,'12312312312',1,'2025-11-22 11:54:28','2025-11-22 11:54:28',1),(5,'hotel',4,2,'heheheehe',1,'2025-11-22 12:31:15','2025-11-22 12:31:15',1),(6,'restaurant',3,2,'cam on b',1,'2025-12-08 12:46:35','2025-12-08 12:46:35',1);
/*!40000 ALTER TABLE `review_replies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `review_reports`
--

DROP TABLE IF EXISTS `review_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `review_reports` (
  `report_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `review_type` enum('hotel','restaurant','tour','attraction','provider') NOT NULL,
  `review_id` int NOT NULL,
  `reply_id` int DEFAULT NULL,
  `report_reason` enum('spam','inappropriate','false_information','harassment','other') NOT NULL,
  `report_description` text,
  `report_status` enum('pending','reviewed','resolved','dismissed') NOT NULL DEFAULT 'pending',
  `admin_notes` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`report_id`),
  KEY `fk_review_report_user` (`user_id`),
  KEY `fk_review_report_reply` (`reply_id`),
  CONSTRAINT `fk_review_report_reply` FOREIGN KEY (`reply_id`) REFERENCES `review_replies` (`reply_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_review_report_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `review_reports`
--

LOCK TABLES `review_reports` WRITE;
/*!40000 ALTER TABLE `review_reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `review_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `search_history`
--

DROP TABLE IF EXISTS `search_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `search_history` (
  `search_history_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `search_query` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `search_type` enum('hotel','restaurant','tour','attraction','general') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'general',
  `item_type` enum('hotel','restaurant','tour','attraction','area') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `item_id` int DEFAULT NULL,
  `item_title` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `item_location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `item_thumbnail_url` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `search_timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `clicked` tinyint(1) NOT NULL DEFAULT '0',
  `click_timestamp` datetime DEFAULT NULL,
  PRIMARY KEY (`search_history_id`),
  KEY `idx_user_timestamp` (`user_id`,`search_timestamp` DESC),
  KEY `idx_user_clicked` (`user_id`,`clicked`,`search_timestamp` DESC),
  KEY `idx_search_query` (`search_query`),
  KEY `idx_item_type_id` (`item_type`,`item_id`),
  CONSTRAINT `fk_search_history_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores user search history and clicked items for personalized recommendations';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `search_history`
--

LOCK TABLES `search_history` WRITE;
/*!40000 ALTER TABLE `search_history` DISABLE KEYS */;
INSERT INTO `search_history` VALUES (1,1,'ha noi','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 04:48:25',0,NULL),(2,1,'ha noi','hotel','hotel',13,'khách sạn hà nội','','https://res.cloudinary.com/tripfinity-img/image/upload/v1764594798/assets/aabfde0e-6e35-4983-a773-1631360fd81d.png','2025-12-11 04:48:27',1,'2025-12-11 04:48:27'),(3,1,'ha noi','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 04:48:45',0,NULL),(4,1,'ha noi','hotel','hotel',13,'khách sạn hà nội','','https://res.cloudinary.com/tripfinity-img/image/upload/v1764594798/assets/aabfde0e-6e35-4983-a773-1631360fd81d.png','2025-12-11 04:48:51',1,'2025-12-11 04:48:51'),(5,1,'bao tang','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 04:48:56',0,NULL),(6,1,'bao tang','attraction','attraction',2,'bảo tàng việt nam đà nẵng','Đà Nẵng','https://res.cloudinary.com/tripfinity-img/image/upload/v1765029990/assets/0bad3040-c68f-4883-86c8-b83fd18ba3e5.png','2025-12-11 04:48:58',1,'2025-12-11 04:48:58'),(7,1,'ha noi','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 04:49:28',0,NULL),(8,1,'ha noi','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 04:49:42',0,NULL),(9,1,'ha noi','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 04:49:44',0,NULL),(10,1,'ha noi','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 04:52:24',0,NULL),(11,1,'du lich','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 04:55:01',0,NULL),(12,1,'du lich','tour','tour',8,'Tour du lịch cảnh hồ chí minh','TP Hồ Chí Minh','https://res.cloudinary.com/tripfinity-img/image/upload/v1765289412/assets/c66d00fe-e2c0-431c-be47-84d2b150468e.png','2025-12-11 04:55:03',1,'2025-12-11 04:55:03'),(13,1,'bao tang','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 05:14:25',0,NULL),(14,1,'bao tang','attraction','attraction',2,'bảo tàng việt nam đà nẵng','Đà Nẵng','https://res.cloudinary.com/tripfinity-img/image/upload/v1765029990/assets/0bad3040-c68f-4883-86c8-b83fd18ba3e5.png','2025-12-11 05:14:27',1,'2025-12-11 05:14:27'),(15,1,'ha noi','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 07:26:37',0,NULL),(16,1,'ha noi','tour','tour',7,'231','Hà Nội','https://res.cloudinary.com/tripfinity-img/image/upload/v1764926959/assets/d4bf6fac-7ab0-4fc6-9cc9-f3f2e51b3a99.png','2025-12-11 07:28:17',1,'2025-12-11 07:28:17'),(17,1,'bao tang','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 07:29:46',0,NULL),(18,1,'ha noi','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 07:30:03',0,NULL),(19,1,'ha noi','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 07:38:04',0,NULL),(20,1,'ha noi','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 08:00:18',0,NULL),(21,1,'ha noi','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 08:04:20',0,NULL),(22,1,'ha noi','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 08:09:51',0,NULL),(23,1,'ha noi','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 08:17:00',0,NULL),(24,1,'ha noi','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 08:26:29',0,NULL),(25,1,'ha noi','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 08:56:32',0,NULL),(26,1,'ha noi','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 09:00:58',0,NULL),(27,1,'ha noi','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 09:15:01',0,NULL),(28,1,'ha nang','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 09:22:48',0,NULL),(29,1,'da nang','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 09:22:57',0,NULL),(30,1,'ha nang','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 09:31:43',0,NULL),(31,1,'da nang','general',NULL,NULL,NULL,NULL,NULL,'2025-12-11 09:31:50',0,NULL),(32,1,'ha noi','general',NULL,NULL,NULL,NULL,NULL,'2025-12-13 14:08:13',0,NULL),(33,1,'viet','general',NULL,NULL,NULL,NULL,NULL,'2025-12-13 14:17:45',0,NULL),(34,1,'viet','hotel','hotel',15,'khách sạn bà rịa','TP. Hồ Chí Minh','https://res.cloudinary.com/tripfinity-img/image/upload/v1764597749/assets/7e06be64-129d-41f7-a465-62f71f886249.png','2025-12-13 14:17:48',1,'2025-12-13 14:17:48'),(35,1,'khách sạn bà rịa','hotel','hotel',15,'khách sạn bà rịa','TP. Hồ Chí Minh','https://res.cloudinary.com/tripfinity-img/image/upload/v1764597749/assets/7e06be64-129d-41f7-a465-62f71f886249.png','2025-12-13 14:18:03',1,'2025-12-13 14:18:03'),(36,1,'khách sạn bà rịa','hotel','hotel',15,'khách sạn bà rịa','TP. Hồ Chí Minh','https://res.cloudinary.com/tripfinity-img/image/upload/v1764597749/assets/7e06be64-129d-41f7-a465-62f71f886249.png','2025-12-13 14:20:01',1,'2025-12-13 14:20:01'),(37,1,'khách sạn bà rịa','hotel','hotel',15,'khách sạn bà rịa','TP. Hồ Chí Minh','https://res.cloudinary.com/tripfinity-img/image/upload/v1764597749/assets/7e06be64-129d-41f7-a465-62f71f886249.png','2025-12-13 14:22:13',1,'2025-12-13 14:22:13'),(38,1,'khách sạn bà rịa','hotel','hotel',15,'khách sạn bà rịa','TP. Hồ Chí Minh','https://res.cloudinary.com/tripfinity-img/image/upload/v1764597749/assets/7e06be64-129d-41f7-a465-62f71f886249.png','2025-12-13 14:23:15',1,'2025-12-13 14:23:15'),(39,1,'khách sạn bà rịa','hotel','hotel',15,'khách sạn bà rịa','TP. Hồ Chí Minh','https://res.cloudinary.com/tripfinity-img/image/upload/v1764597749/assets/7e06be64-129d-41f7-a465-62f71f886249.png','2025-12-13 14:28:06',1,'2025-12-13 14:28:06'),(40,1,'khách sạn bà rịa','hotel','hotel',15,'khách sạn bà rịa','TP. Hồ Chí Minh','https://res.cloudinary.com/tripfinity-img/image/upload/v1764597749/assets/7e06be64-129d-41f7-a465-62f71f886249.png','2025-12-13 14:36:38',1,'2025-12-13 14:36:38');
/*!40000 ALTER TABLE `search_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tour_bookings`
--

DROP TABLE IF EXISTS `tour_bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tour_bookings` (
  `booking_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `tour_id` int NOT NULL,
  `booking_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `num_adults` int NOT NULL DEFAULT '1',
  `special_requests` text COMMENT 'Yêu cầu đặc biệt',
  `total_price` decimal(12,2) NOT NULL,
  `deposit_amount` decimal(12,2) DEFAULT NULL COMMENT 'Tiền đặt cọc',
  `currency_code` varchar(3) NOT NULL,
  `payment_method` varchar(50) DEFAULT NULL COMMENT 'Phương thức thanh toán',
  `booking_status` enum('cancelled','completed','confirmed','pending','refunded') NOT NULL,
  `e_ticket_url` varchar(512) DEFAULT NULL,
  `qr_code_data` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `provider_id` int DEFAULT NULL,
  `channel` varchar(100) DEFAULT NULL,
  `hold_until` datetime DEFAULT NULL,
  `provider_seen` tinyint(1) NOT NULL DEFAULT '0',
  `provider_notes` text,
  `provider_confirmed` int NOT NULL,
  `provider_confirmed_at` datetime DEFAULT NULL COMMENT 'Thời điểm xác nhận',
  PRIMARY KEY (`booking_id`),
  KEY `fk_tour_booking_user` (`user_id`),
  KEY `fk_tour_booking_tour` (`tour_id`),
  KEY `idx_tour_bookings_provider` (`provider_id`),
  KEY `idx_tour_bookings_status` (`booking_status`),
  KEY `idx_tour_bookings_provider_confirmed` (`provider_confirmed`),
  CONSTRAINT `fk_tour_booking_provider` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`provider_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_tour_booking_tour` FOREIGN KEY (`tour_id`) REFERENCES `tours` (`tour_id`),
  CONSTRAINT `fk_tour_booking_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tour_bookings`
--

LOCK TABLES `tour_bookings` WRITE;
/*!40000 ALTER TABLE `tour_bookings` DISABLE KEYS */;
INSERT INTO `tour_bookings` VALUES (1,1,8,'2025-12-09 14:18:18','2025-12-12','2025-12-14',2,NULL,2000000.00,NULL,'VND',NULL,'confirmed',NULL,NULL,'2025-12-09 14:18:18','2025-12-09 15:34:31',1,NULL,NULL,0,'people=2',1,'2025-12-09 15:34:31'),(2,1,8,'2025-12-09 14:19:53','2025-12-10','2025-12-11',1,NULL,1000000.00,NULL,'VND',NULL,'confirmed',NULL,NULL,'2025-12-09 14:19:53','2025-12-09 15:27:44',1,'mobile_app',NULL,0,'people=1',1,'2025-12-09 15:27:44'),(3,1,8,'2025-12-09 15:06:24','2025-12-10','2025-12-11',1,NULL,1000000.00,NULL,'VND',NULL,'confirmed',NULL,NULL,'2025-12-09 15:06:24','2025-12-09 15:27:35',1,NULL,NULL,0,'people=1',1,'2025-12-09 15:27:35'),(4,1,8,'2025-12-09 15:35:01','2025-12-10','2025-12-11',1,NULL,1000000.00,NULL,'VND',NULL,'confirmed',NULL,NULL,'2025-12-09 15:35:01','2025-12-10 14:15:22',1,NULL,NULL,0,'people=1',1,'2025-12-10 14:15:22'),(5,1,8,'2025-12-10 13:58:46','2025-12-11','2025-12-12',1,NULL,1000000.00,NULL,'VND',NULL,'confirmed',NULL,NULL,'2025-12-10 13:58:46','2025-12-10 14:14:56',1,NULL,NULL,0,'people=1',1,'2025-12-10 14:14:56');
/*!40000 ALTER TABLE `tour_bookings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tour_payments`
--

DROP TABLE IF EXISTS `tour_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tour_payments` (
  `payment_id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `user_id` int NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `currency_code` varchar(3) NOT NULL,
  `payment_method` enum('counter','mastercard','momo','other','paypal','visa','vnpay','zalopay') NOT NULL,
  `transaction_id` varchar(255) NOT NULL,
  `payment_status` enum('failed','pending','refunded','success') NOT NULL,
  `payment_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`payment_id`),
  UNIQUE KEY `transaction_id` (`transaction_id`),
  KEY `fk_tour_pay_booking` (`booking_id`),
  KEY `fk_tour_pay_user` (`user_id`),
  CONSTRAINT `fk_tour_pay_booking` FOREIGN KEY (`booking_id`) REFERENCES `tour_bookings` (`booking_id`),
  CONSTRAINT `fk_tour_pay_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tour_payments`
--

LOCK TABLES `tour_payments` WRITE;
/*!40000 ALTER TABLE `tour_payments` DISABLE KEYS */;
INSERT INTO `tour_payments` VALUES (1,1,1,2000000.00,'VND','counter','TOUR_TXN_1_1765289897761','pending','2025-12-09 14:18:18','2025-12-09 14:18:18','2025-12-09 14:18:18'),(2,2,1,1000000.00,'VND','zalopay','TOUR_TXN_2_1765289992731','success','2025-12-09 14:19:53','2025-12-09 14:19:53','2025-12-09 14:19:53'),(3,3,1,1000000.00,'VND','counter','TOUR_TXN_3_1765292783713','pending','2025-12-09 15:06:24','2025-12-09 15:06:24','2025-12-09 15:06:24'),(4,4,1,1000000.00,'VND','counter','TOUR_TXN_4_1765294501020','pending','2025-12-09 15:35:01','2025-12-09 15:35:01','2025-12-09 15:35:01'),(5,5,1,1000000.00,'VND','counter','TOUR_TXN_5_1765375126415','pending','2025-12-10 13:58:46','2025-12-10 13:58:46','2025-12-10 13:58:46');
/*!40000 ALTER TABLE `tour_payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tour_rating_summaries`
--

DROP TABLE IF EXISTS `tour_rating_summaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tour_rating_summaries` (
  `tour_id` int NOT NULL,
  `avg_rating` decimal(3,2) NOT NULL DEFAULT '0.00',
  `total_reviews` int NOT NULL DEFAULT '0',
  `count_1` int NOT NULL DEFAULT '0',
  `count_2` int NOT NULL DEFAULT '0',
  `count_3` int NOT NULL DEFAULT '0',
  `count_4` int NOT NULL DEFAULT '0',
  `count_5` int NOT NULL DEFAULT '0',
  `avg_guide_quality` decimal(3,2) DEFAULT NULL,
  `avg_itinerary_quality` decimal(3,2) DEFAULT NULL,
  `avg_value_for_money` decimal(3,2) DEFAULT NULL,
  `avg_organization` decimal(3,2) DEFAULT NULL,
  `avg_safety` decimal(3,2) DEFAULT NULL,
  PRIMARY KEY (`tour_id`),
  CONSTRAINT `fk_tour_rating` FOREIGN KEY (`tour_id`) REFERENCES `tours` (`tour_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tour_rating_summaries`
--

LOCK TABLES `tour_rating_summaries` WRITE;
/*!40000 ALTER TABLE `tour_rating_summaries` DISABLE KEYS */;
/*!40000 ALTER TABLE `tour_rating_summaries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tour_review_aspects`
--

DROP TABLE IF EXISTS `tour_review_aspects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tour_review_aspects` (
  `review_id` int NOT NULL,
  `guide_quality` int NOT NULL,
  `itinerary_quality` int NOT NULL,
  `value_for_money` int NOT NULL,
  `organization` int NOT NULL,
  `safety` int NOT NULL,
  PRIMARY KEY (`review_id`),
  CONSTRAINT `fk_tour_aspects_review` FOREIGN KEY (`review_id`) REFERENCES `tour_reviews` (`review_id`) ON DELETE CASCADE,
  CONSTRAINT `tour_review_aspects_chk_1` CHECK ((`guide_quality` between 1 and 5)),
  CONSTRAINT `tour_review_aspects_chk_2` CHECK ((`itinerary_quality` between 1 and 5)),
  CONSTRAINT `tour_review_aspects_chk_3` CHECK ((`value_for_money` between 1 and 5)),
  CONSTRAINT `tour_review_aspects_chk_4` CHECK ((`organization` between 1 and 5)),
  CONSTRAINT `tour_review_aspects_chk_5` CHECK ((`safety` between 1 and 5))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tour_review_aspects`
--

LOCK TABLES `tour_review_aspects` WRITE;
/*!40000 ALTER TABLE `tour_review_aspects` DISABLE KEYS */;
/*!40000 ALTER TABLE `tour_review_aspects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tour_reviews`
--

DROP TABLE IF EXISTS `tour_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tour_reviews` (
  `review_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `tour_id` int NOT NULL,
  `rating` int NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `content` text NOT NULL,
  `image_urls` text,
  `likes_count` int NOT NULL DEFAULT '0',
  `reply_count` int NOT NULL DEFAULT '0',
  `review_status` enum('approved','rejected') NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`review_id`),
  KEY `fk_tour_review_user` (`user_id`),
  KEY `fk_tour_review_tour` (`tour_id`),
  CONSTRAINT `fk_tour_review_tour` FOREIGN KEY (`tour_id`) REFERENCES `tours` (`tour_id`),
  CONSTRAINT `fk_tour_review_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `tour_reviews_chk_1` CHECK ((`rating` between 1 and 5))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tour_reviews`
--

LOCK TABLES `tour_reviews` WRITE;
/*!40000 ALTER TABLE `tour_reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `tour_reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tours`
--

DROP TABLE IF EXISTS `tours`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tours` (
  `tour_id` int NOT NULL AUTO_INCREMENT,
  `provider_id` int NOT NULL,
  `area_id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `service_description` text,
  `location` varchar(255) DEFAULT NULL COMMENT 'Tỉnh/thành phố (tên)',
  `address` varchar(255) DEFAULT NULL COMMENT 'Địa chỉ đầy đủ',
  `latitude` decimal(10,8) DEFAULT NULL COMMENT 'Latitude coordinate',
  `longitude` decimal(11,8) DEFAULT NULL COMMENT 'Longitude coordinate',
  `start_date` date DEFAULT NULL COMMENT 'Ngày bắt đầu tour',
  `end_date` date DEFAULT NULL COMMENT 'Ngày kết thúc tour',
  `price` decimal(12,2) NOT NULL COMMENT 'Giá tour',
  `currency_code` varchar(3) NOT NULL DEFAULT 'VND',
  `capacity` int DEFAULT NULL COMMENT 'Số người tối đa',
  `min_participants` int DEFAULT NULL COMMENT 'Số người tối thiểu để khởi hành',
  `max_participants` int DEFAULT NULL COMMENT 'Số người tối đa',
  `thumbnail_url` varchar(512) DEFAULT NULL,
  `image_urls` json DEFAULT NULL COMMENT 'Array of image URLs (JSON)',
  `badges` varchar(255) DEFAULT NULL,
  `tour_status` enum('archived','disabled','published') NOT NULL,
  `visibility` enum('private_','public_') NOT NULL,
  `is_featured` tinyint(1) NOT NULL DEFAULT '0',
  `duration_days` int DEFAULT NULL COMMENT 'Số ngày tour',
  `difficulty_level` enum('easy','hard','moderate') DEFAULT NULL,
  `departure_location` varchar(255) DEFAULT NULL COMMENT 'Điểm xuất phát',
  `meeting_point` varchar(255) DEFAULT NULL COMMENT 'Điểm tập trung',
  `guide_language` varchar(100) DEFAULT NULL COMMENT 'Ngôn ngữ hướng dẫn viên (deprecated - dùng guide_languages_json)',
  `guide_languages_json` json DEFAULT NULL COMMENT 'Array: ["vietnamese","english","chinese","japanese","korean"]',
  `itinerary_overview` text COMMENT 'Tổng quan lịch trình',
  `itinerary_details_json` json DEFAULT NULL COMMENT 'Chi tiết lịch trình từng ngày: [{"day":1,"title":"","activities":[]}]',
  `inclusive_items` text COMMENT 'Deprecated - dùng included_json',
  `exclusive_items` text COMMENT 'Deprecated - dùng excluded_json',
  `included_json` json DEFAULT NULL COMMENT 'Array: ["hotel","meals","transport","guide","insurance","entrance_fees"]',
  `excluded_json` json DEFAULT NULL COMMENT 'Array: ["flights","visa","tips","personal_expenses"]',
  `cancellation_policy` text COMMENT 'Chính sách hủy tour',
  `policies_text` text COMMENT 'Các chính sách khác',
  `tour_type` enum('custom','group','private_') DEFAULT NULL,
  `categories_json` json DEFAULT NULL COMMENT 'Array: ["culture","nature","adventure","food","beach","mountain","city","historical"]',
  `services_json` json DEFAULT NULL COMMENT 'Array: ["pickup","airport_transfer","photography","bike_rental","special_meals"]',
  `slug` varchar(255) DEFAULT NULL,
  `seo_title` varchar(255) DEFAULT NULL,
  `seo_description` varchar(512) DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`tour_id`),
  UNIQUE KEY `uq_tours_slug` (`slug`),
  KEY `fk_tours_area` (`area_id`),
  KEY `idx_tours_provider` (`provider_id`),
  KEY `idx_tours_status` (`tour_status`),
  KEY `idx_tours_difficulty` (`difficulty_level`),
  KEY `idx_tours_featured` (`is_featured`),
  KEY `idx_tours_tour_type` (`tour_type`),
  CONSTRAINT `fk_tours_area` FOREIGN KEY (`area_id`) REFERENCES `areas` (`area_id`),
  CONSTRAINT `fk_tours_provider` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`provider_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tours`
--

LOCK TABLES `tours` WRITE;
/*!40000 ALTER TABLE `tours` DISABLE KEYS */;
INSERT INTO `tours` VALUES (1,1,48,'tour hạ long vip','kjdsfkhjfdskhjfsdkhjsdf','Quảng Ninh','Hà Trung, Phường Hà Lầm, Tỉnh Quảng Ninh, 01040, Việt Nam',20.96023735,107.12753534,'2025-12-06','2025-12-13',10.00,'VND',23,1,21,'https://res.cloudinary.com/tripfinity-img/image/upload/v1764683702/assets/c69c7b6d-a691-4709-b84e-2516118eb4f8.jpg','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1764683704/assets/c349e352-d414-4585-be72-96f35685a19b.jpg\"]','[\"budget_friendly\",\"recommended\",\"hot_deal\"]','published','public_',1,3,'easy','32','32',NULL,'[\"korean\"]','213123','[{\"day\": 1, \"title\": \"423423\", \"activities\": [\"32432423423432\"]}]',NULL,NULL,'[\"lunch\", \"guide\"]','[\"flights\", \"alcohol\"]','213 312132','123132213','private_','[\"adventure\", \"mountain\"]','[\"photographer\", \"videographer\", \"water_bottle\"]','tour-ha-long-219274765','231213213312','21312312321321',NULL,'2025-12-02 12:14:35','2025-12-12 12:42:30'),(2,1,24,'34234','123312123123321','Hà Nội','Viện Bảo tàng Lịch sử Việt Nam, 1, Phố Tràng Tiền, Phường Hoàn Kiếm, Hà Nội, 11024, Việt Nam',21.02458489,105.85932255,'2025-12-13','2025-12-19',123.00,'VND',123,213,123,NULL,NULL,'hot_deal,family_friendly','published','public_',1,23,'moderate','213','123',NULL,'[\"vietnamese\", \"french\"]','213312321','[{\"day\": 1, \"title\": \"123123\", \"activities\": [\"12312321\"]}]',NULL,NULL,'[\"dinner\", \"transport\"]','[\"drinks\", \"alcohol\"]','123123','123123','private_','[\"adventure\", \"mountain\"]','[\"professional_guide\", \"videographer\"]','34234-966977050','123123','21312321321',NULL,'2025-12-02 12:23:44','2025-12-02 12:23:44'),(3,1,14,'hạ long việt siêu tour','sdffsd32423423423','Cao Bằng','Xã Nam Tuấn, Tỉnh Cao Bằng, 84026, Việt Nam',22.74708676,106.13094058,'2025-12-02','2025-12-05',1123.00,'VND',123,123,123,'https://res.cloudinary.com/tripfinity-img/image/upload/v1764679228/assets/e84fefba-b5b7-442a-a317-1f5ccdc73881.png','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1764683621/assets/55fe19d4-5334-4827-8cae-a13174723544.jpg\"]','[\"luxury\",\"popular\"]','published','public_',1,3,'moderate','234','324',NULL,'[\"vietnamese\", \"french\"]','23423423','[{\"day\": 1, \"title\": \"423424\", \"activities\": [\"23423432\"]}]',NULL,NULL,'[\"guide\", \"lunch\", \"insurance\"]','[\"flights\", \"alcohol\"]','324234','234234','custom','[\"adventure\", \"wildlife\"]','[\"bike_rental\", \"halal_meals\", \"videographer\"]','ha-long-tour-687200369','234234','234234234324',NULL,'2025-12-02 12:40:23','2025-12-02 13:54:16'),(4,1,15,'đà nẵng tour','123123123','Đà Nẵng','Kem Dừa Mã Lai, 47, Đường Yên Bái, Phước Ninh, Phường Hải Châu, Thành phố Đà Nẵng, 50207, Việt Nam',16.06775257,108.22238551,'2025-12-02','2025-12-06',1312.00,'VND',21,12,123,'https://res.cloudinary.com/tripfinity-img/image/upload/v1764680388/assets/24536d0e-a271-4021-b038-f3af02f04e92.png','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1764680391/assets/c841e8c7-b325-434e-9fad-18b85bc9ab81.jpg\"]','[\"best_seller\",\"family_friendly\"]','published','public_',0,12,'easy','3213123','3123123',NULL,'[\"korean\", \"spanish\"]','12312312','[{\"day\": 1, \"title\": \"123123\", \"activities\": [\"123123123\"]}]',NULL,NULL,'[\"hotel\", \"transport\"]','[\"flights\", \"alcohol\"]','12312312','21312321','custom','[\"beach\", \"food\"]','[\"wifi_on_board\", \"halal_meals\"]','da-nang-tour-425313069','123123123','12312321',NULL,'2025-12-02 12:59:52','2025-12-02 12:59:52'),(5,1,24,'hà nội ','123123231123','Hà Nội','Atelier Coffee, Phố Tôn Thất Thiệp, Phường Hoàn Kiếm, Hà Nội, 11120, Việt Nam',21.02985557,105.84286155,'2025-12-24','2025-12-25',13213.00,'VND',32,32,32,'https://res.cloudinary.com/tripfinity-img/image/upload/v1764920519/assets/2c4890cf-2b76-4dcb-a5b5-a9e1bde990dd.jpg','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1764920521/assets/01d28813-c645-4783-a8bc-d938ae873f78.jpg\"]','[\"best_seller\",\"adventure\"]','published','public_',1,2,'easy','32','32',NULL,'[\"russian\"]','234','[{\"day\": 1, \"title\": \"342\", \"activities\": [\"342\"]}]',NULL,NULL,'[\"breakfast\", \"lunch\"]','[\"drinks\", \"phone_calls\"]','234','234','group','[\"city\", \"historical\"]','[\"car_rental\", \"special_meals\"]','ha-noi-113553221','234','234',NULL,'2025-12-05 07:42:00','2025-12-05 07:42:00'),(6,1,24,'ha nọi','312132231','Hà Nội','Cục Thể dục Thể thao Việt Nam, 36, Phố Trần Phú, Phường Ba Đình, Hà Nội, 11120, Việt Nam',21.03085699,105.84247531,'2025-12-05','2025-12-06',1123.00,'VND',321,312,312,'https://res.cloudinary.com/tripfinity-img/image/upload/v1764922269/assets/6928d92b-424e-4af7-b633-142abf049ad2.jpg','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1764922271/assets/93b0ac0d-4f84-4632-b2ea-17b925a77190.jpg\"]','best_seller,luxury','published','public_',0,123,'easy','12','312',NULL,'[\"korean\", \"spanish\"]','2132','[{\"day\": 1, \"title\": \"213\", \"activities\": [\"312\"]}]',NULL,NULL,'[\"snacks\", \"water\"]','[\"laundry\", \"phone_calls\"]','213','231312','private_','[\"culture\"]','[\"car_rental\", \"special_meals\"]','ha-noi-180559193','231312','21312123',NULL,'2025-12-05 08:11:10','2025-12-05 08:11:10'),(7,1,24,'231','123321123321','Hà Nội','Đường NB-2, Khu công nghiệp Nội Bài, Xã Sóc Sơn, Hà Nội, Việt Nam',21.22977370,105.81235840,'2025-12-05','2025-12-06',1.00,'VND',21,21,21,'https://res.cloudinary.com/tripfinity-img/image/upload/v1764926959/assets/d4bf6fac-7ab0-4fc6-9cc9-f3f2e51b3a99.png','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1764926961/assets/a43a73d5-81b9-48bd-a0a1-394d5c4ab42b.jpg\"]','[\"best_seller\"]','published','public_',0,2,'easy','312','312',NULL,'[\"russian\"]','132123312','[{\"day\": 1, \"title\": \"123\", \"activities\": [\"123\"]}]',NULL,NULL,'[\"hotel\"]','[\"flights\"]','312','123','group','[\"nightlife\"]','[\"professional_guide\", \"porter_service\"]','231-494560071','213','32',NULL,'2025-12-05 09:29:20','2025-12-05 09:29:20'),(8,1,58,'Tour du lịch cảnh hồ chí minh','Mô tả chi tiết lịch trình tour du lịch hồ chí minh','TP Hồ Chí Minh','Hẻm 927 Cách mạng tháng 8, Phường Tân Sơn Nhất, Thành phố Thủ Đức, Thành phố Hồ Chí Minh, 72117, Việt Nam',10.78933977,106.65900707,'2025-12-09','2025-12-09',1000000.00,'VND',20,1,18,'https://res.cloudinary.com/tripfinity-img/image/upload/v1765289412/assets/c66d00fe-e2c0-431c-be47-84d2b150468e.png','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1765289416/assets/25b93ab9-c608-4bb4-a6ca-644041d5d633.png\", \"https://res.cloudinary.com/tripfinity-img/image/upload/v1765289420/assets/2f23ca94-7d04-4301-ad7f-e9ba85586ea3.png\"]','[\"best_seller\",\"hot_deal\"]','published','public_',1,1,'moderate','Ga Hồ Chí Minh','Trước Ga',NULL,'[\"chinese\", \"french\", \"spanish\"]','Mô tả lịch trình','[{\"day\": 1, \"title\": \"Khám phá\", \"activities\": [\"Tham quan quanh cảnh hồ chí minh\"]}]',NULL,NULL,'[\"guide\", \"water\", \"souvenirs\"]','[\"flights\", \"alcohol\", \"phone_calls\"]','Hủy tour','Không có chính sách khác','group','[\"culture\", \"beach\", \"wildlife\", \"historical\", \"mountain\"]','[\"pickup\", \"car_rental\", \"bike_rental\", \"motorcycle_rental\", \"halal_meals\", \"first_aid_kit\", \"porter_service\", \"sun_protection\"]','tour-du-lich-canh-ho-chi-minh-640777685','tour-du-lich-canh-ho-chi-minh-6407776852312','tour-du-lich-canh-ho-chi-minh-6407776852312 mô tả',NULL,'2025-12-09 14:10:20','2025-12-09 14:10:20'),(9,1,35,'trest tour','123123','Lâm Đồng','Tổ dân phố 3, Gia Nghĩa, Phường Bắc Gia Nghĩa, Tỉnh Lâm Đồng, Việt Nam',11.99710779,107.70537791,'2025-12-12','2025-12-23',112.00,'VND',12,12,12,'https://res.cloudinary.com/tripfinity-img/image/upload/v1765544302/assets/81f5d451-f690-4782-966f-b96e7d071538.jpg','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1765544306/assets/d97541d6-07c0-4615-ac1f-575af4570b48.png\"]','[\"hot_deal\",\"luxury\"]','published','public_',1,12,'easy','12','1',NULL,'[\"german\", \"spanish\"]','123123','[{\"day\": 1, \"title\": \"123\", \"activities\": [\"1231\"]}]',NULL,NULL,'[\"entrance_fees\", \"activities\"]','[\"drinks\", \"personal_expenses\"]','123','132132','group','[\"city\", \"wildlife\"]','[\"airport_transfer\", \"travel_insurance\", \"life_jacket\"]','trest-tour-834752448','123132','1231231321123123',NULL,'2025-12-12 12:58:26','2025-12-12 12:58:26'),(10,1,24,'1231','1233123123','Hà Nội','Free Hanoi City Tour everyday, 120, Phố Hàng Bông, Khu phố cổ, Phường Hoàn Kiếm, Hà Nội, 11024, Việt Nam',21.02961523,105.84595146,'2025-12-12','2025-12-12',1123.00,'VND',12,12,12,'https://res.cloudinary.com/tripfinity-img/image/upload/v1765546746/assets/e5819593-3153-4a6b-be56-e486d8d7271d.jpg','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1765546749/assets/3c2a6010-7721-4253-88db-0df0bc18d543.png\"]','[\"hot_deal\"]','published','public_',1,1,'easy','13','31',NULL,'[\"german\"]','132','[{\"day\": 1, \"title\": \"132\", \"activities\": [\"123\"]}]',NULL,NULL,'[\"hotel\"]','[\"extra_activities\"]','132','123','private_','[\"culture\"]','[\"pickup\", \"vegetarian_options\", \"wheelchair_accessible\"]','1231-731686894','213312','231312','2025-12-12 13:39:10','2025-12-12 13:39:10','2025-12-12 13:39:10'),(11,1,24,'tỏu sfap','21132123','Hà Nội','68, Đường Lê Duẩn, Phường Cửa Nam, Hà Nội, 11060, Việt Nam',21.02713168,105.84131660,'2025-12-12','2025-12-13',1565.00,'VND',2,2,2,'https://res.cloudinary.com/tripfinity-img/image/upload/v1765547705/assets/c07dbdbd-bbeb-45c9-a123-816003cebdd9.png','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1765547709/assets/c637d442-0d52-41e5-bdb9-903f82f38f8a.png\"]','[\"popular\",\"adventure\",\"family_friendly\"]','published','public_',1,2,'easy','11','31',NULL,'[\"korean\", \"french\"]','321','[{\"day\": 1, \"title\": \"213\", \"activities\": [\"213\"]}]','equipment,activities','extra_activities','[\"equipment\", \"activities\"]','[\"extra_activities\"]','213','231312','group','[\"city\", \"shopping\"]','[\"vegetarian_options\", \"halal_meals\"]','tou-sfap-750320868','123123231','123123123123','2025-12-12 13:55:10','2025-12-12 13:55:10','2025-12-12 13:55:10'),(12,1,47,'tour vip ','2342342','Quảng Ngãi','Đăk Nông, Đăk Tờ Kan, Xã Đăk Tờ Kan, Tỉnh Quảng Ngãi, Việt Nam',14.80431414,107.86931690,'2025-12-12','2026-01-14',132.00,'VND',2,2,2,'https://res.cloudinary.com/tripfinity-img/image/upload/v1765548231/assets/21234271-185f-4b90-8eda-e02610e7bbd2.png','[\"https://res.cloudinary.com/tripfinity-img/image/upload/v1765548235/assets/0b318872-7dc0-4689-9b40-1e56a08fd446.png\"]','[\"best_seller\",\"budget_friendly\",\"family_friendly\"]','published','public_',1,34,'easy','23','23','korean,french','[\"korean\", \"french\"]','234234','[{\"day\": 1, \"title\": \"234\", \"activities\": [\"23432\"]}]','hotel,transport','flights','[\"hotel\", \"transport\"]','[\"flights\"]','342234','234324','group','[\"culture\", \"mountain\"]','[\"audio_guide\", \"travel_insurance\"]','tour-vip-863823374','324324','234234234','2025-12-12 14:03:55','2025-12-12 14:03:55','2025-12-12 14:03:55');
/*!40000 ALTER TABLE `tours` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_badges`
--

DROP TABLE IF EXISTS `user_badges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_badges` (
  `user_badge_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `badge_id` int NOT NULL,
  `unlocked_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_badge_id`),
  UNIQUE KEY `uk_user_badge` (`user_id`,`badge_id`),
  KEY `fk_user_badges_user` (`user_id`),
  KEY `fk_user_badges_badge` (`badge_id`),
  CONSTRAINT `fk_user_badges_badge` FOREIGN KEY (`badge_id`) REFERENCES `badges` (`badge_id`),
  CONSTRAINT `fk_user_badges_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_badges`
--

LOCK TABLES `user_badges` WRITE;
/*!40000 ALTER TABLE `user_badges` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_badges` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `avatar_url` varchar(512) DEFAULT NULL,
  `account_role` enum('tourist','provider','admin') NOT NULL,
  `account_status` enum('active','banned') NOT NULL DEFAULT 'active',
  `date_of_birth` date DEFAULT NULL,
  `gender` enum('male','female','other') DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `otp_expiry_time` datetime DEFAULT NULL,
  `reset_otp` varchar(6) DEFAULT NULL,
  `fcm_token` varchar(255) DEFAULT NULL COMMENT 'Firebase Cloud Messaging token for push notifications',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_fcm_token` (`fcm_token`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'tcshopfd@gmail.com','$2a$10$xSDN93/H/sbcE0PA8E/Jpuyne42GxyfVkUluN2A8gOPdOjN.Y56ou','congdeptrai','0987654321','https://res.cloudinary.com/tripfinity-img/image/upload/v1761624160/assets/d8982462-1bb9-4627-821f-eae64034d7df.png','tourist','active',NULL,NULL,'2025-10-28 04:02:40','2025-12-13 06:35:06',NULL,NULL,'dK7JLaMNTiSPbBcME5QgXE:APA91bGXMhQeXT8f233ZLhdXODrNzHKrwfvuIgKCTHIz9Z5F2GlDqAoG7SlRrIzoQ6mahgjyFXCeMzlFBrTIgTk-NmXQumRTDFKtUgQYZbju1EGbhL0mu4o'),(2,'tripfinity2025@gmail.com','$2a$10$rTz38I0VB8v4l3ocpCFY/uyrDoe15WN/SYly96NCxTIvk5WfBB05W','TripFinity',NULL,'https://res.cloudinary.com/tripfinity-img/image/upload/v1761624230/assets/698f150d-992d-493f-87df-ea43ee479001.png','provider','active',NULL,NULL,'2025-10-28 04:03:50','2025-10-28 04:03:50',NULL,NULL,NULL),(7,'nguyenmin4869@gmail.com','$2a$10$cZWsO0E9xUEeWS6aMxi/EexFdcM49cgAkMUqQaXFApmCuuSwXNqoW','Công Nguyễn',NULL,'https://res.cloudinary.com/tripfinity-img/image/upload/v1764924345/assets/53c26ece-d418-4ca8-82a2-36f42cdf1239.png','provider','active',NULL,NULL,'2025-12-05 08:45:44','2025-12-05 08:45:44',NULL,NULL,NULL),(8,'nguyenthanhcong4869@gmail.com','$2a$10$UV24xUX99Q.tjztOJ2P...fhgGXPvRtT5PWBCP0VR8NvrAvdjAbl.','Nguyễn Thành Công',NULL,'https://res.cloudinary.com/tripfinity-img/image/upload/v1764926209/assets/f0ba5f58-505d-45ea-8db0-6d67b5988bed.jpg','provider','active',NULL,NULL,'2025-12-05 09:16:48','2025-12-05 09:16:48',NULL,NULL,NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-14 11:06:51
