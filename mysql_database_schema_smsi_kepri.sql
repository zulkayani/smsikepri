-- ==============================================================================
-- DATABASE SCHEMA: SMSI KEPRI (Serikat Media Siber Indonesia Prov. Kepri)
-- RDBMS: MySQL 8.0+ / MariaDB 10.4+
-- Integrated with Laravel Backend & Bootstrap 5 Frontend
-- ==============================================================================

CREATE DATABASE IF NOT EXISTS `smsi_kepri_db` 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE `smsi_kepri_db`;

-- Disable foreign key checks for clean migration
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `activity_logs`;
DROP TABLE IF EXISTS `system_settings`;
DROP TABLE IF EXISTS `member_applications`;
DROP TABLE IF EXISTS `galleries`;
DROP TABLE IF EXISTS `agendas`;
DROP TABLE IF EXISTS `officers`;
DROP TABLE IF EXISTS `media_members`;
DROP TABLE IF EXISTS `news_articles`;
DROP TABLE IF EXISTS `categories`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `roles`;

SET FOREIGN_KEY_CHECKS = 1;

-- ==============================================================================
-- 1. TABLE: ROLES (Hak Akses Pengguna)
-- ==============================================================================
CREATE TABLE `roles` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(50) NOT NULL UNIQUE,
    `display_name` VARCHAR(100) NOT NULL,
    `description` VARCHAR(255) NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==============================================================================
-- 2. TABLE: USERS (Manajemen Pengguna Admin)
-- ==============================================================================
CREATE TABLE `users` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `role_id` BIGINT UNSIGNED NOT NULL,
    `name` VARCHAR(150) NOT NULL,
    `email` VARCHAR(150) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `avatar` VARCHAR(255) NULL,
    `status` ENUM('Active', 'Inactive', 'Suspended') DEFAULT 'Active',
    `remember_token` VARCHAR(100) NULL,
    `email_verified_at` TIMESTAMP NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_users_roles` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==============================================================================
-- 3. TABLE: CATEGORIES (Kategori Berita)
-- ==============================================================================
CREATE TABLE `categories` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL UNIQUE,
    `slug` VARCHAR(120) NOT NULL UNIQUE,
    `description` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_categories_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==============================================================================
-- 4. TABLE: NEWS_ARTICLES (Berita & Publikasi)
-- ==============================================================================
CREATE TABLE `news_articles` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `category_id` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `title` VARCHAR(255) NOT NULL,
    `slug` VARCHAR(255) NOT NULL UNIQUE,
    `thumbnail` VARCHAR(255) NULL,
    `summary` TEXT NOT NULL,
    `content` LONGTEXT NOT NULL,
    `author_name` VARCHAR(100) DEFAULT 'Redaksi SMSI Kepri',
    `status` ENUM('Draft', 'Published', 'Archived') DEFAULT 'Published',
    `views_count` INT UNSIGNED DEFAULT 0,
    `published_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_news_categories` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_news_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT,
    INDEX `idx_news_status_published` (`status`, `published_at`),
    INDEX `idx_news_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==============================================================================
-- 5. TABLE: MEDIA_MEMBERS (Direktori Perusahaan Media Anggota)
-- ==============================================================================
CREATE TABLE `media_members` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `registration_number` VARCHAR(50) UNIQUE NULL,
    `company_name` VARCHAR(150) NOT NULL,
    `media_name` VARCHAR(150) NOT NULL,
    `leader_name` VARCHAR(100) NOT NULL,
    `editor_in_chief` VARCHAR(100) NOT NULL,
    `regency_city` ENUM('Batam', 'Tanjungpinang', 'Karimun', 'Bintan', 'Natuna', 'Anambas', 'Lingga') NOT NULL,
    `address` TEXT NOT NULL,
    `website_url` VARCHAR(255) NOT NULL,
    `official_email` VARCHAR(150) NOT NULL,
    `phone_number` VARCHAR(30) NOT NULL,
    `joined_year` YEAR NOT NULL,
    `status` ENUM('Terverifikasi Dewan Pers', 'Anggota Aktif SMSI', 'Suspended') DEFAULT 'Anggota Aktif SMSI',
    `logo_url` VARCHAR(255) NULL,
    `description` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_media_city` (`regency_city`),
    INDEX `idx_media_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==============================================================================
-- 6. TABLE: OFFICERS (Struktur Pengurus Organisasi)
-- ==============================================================================
CREATE TABLE `officers` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(150) NOT NULL,
    `role_position` VARCHAR(100) NOT NULL,
    `division` VARCHAR(100) NOT NULL DEFAULT 'Pengurus Provinsi',
    `regency_city` ENUM('Provinsi', 'Batam', 'Tanjungpinang', 'Karimun', 'Bintan', 'Natuna', 'Anambas', 'Lingga') DEFAULT 'Provinsi',
    `period` VARCHAR(30) DEFAULT '2024 - 2029',
    `photo_url` VARCHAR(255) NULL,
    `display_order` INT DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==============================================================================
-- 7. TABLE: AGENDAS (Agenda & Program Kegiatan)
-- ==============================================================================
CREATE TABLE `agendas` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(255) NOT NULL,
    `event_date` VARCHAR(100) NOT NULL,
    `location` VARCHAR(255) NOT NULL,
    `description` TEXT NOT NULL,
    `status` ENUM('Akan Datang', 'Pendaftaran Dibuka', 'Selesai', 'Dibatalkan') DEFAULT 'Akan Datang',
    `banner_url` VARCHAR(255) NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==============================================================================
-- 8. TABLE: GALLERIES (Galeri Foto & Dokumentasi Video)
-- ==============================================================================
CREATE TABLE `galleries` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(255) NOT NULL,
    `category` VARCHAR(50) NOT NULL DEFAULT 'Pelantikan',
    `type` ENUM('Photo', 'Video') DEFAULT 'Photo',
    `media_url` VARCHAR(255) NOT NULL,
    `documentation_date` DATE NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==============================================================================
-- 9. TABLE: MEMBER_APPLICATIONS (Pendaftaran Anggota Baru)
-- ==============================================================================
CREATE TABLE `member_applications` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `company_name` VARCHAR(150) NOT NULL,
    `media_name` VARCHAR(150) NOT NULL,
    `regency_city` ENUM('Batam', 'Tanjungpinang', 'Karimun', 'Bintan', 'Natuna', 'Anambas', 'Lingga') NOT NULL,
    `leader_name` VARCHAR(100) NOT NULL,
    `editor_in_chief` VARCHAR(100) NOT NULL,
    `official_email` VARCHAR(150) NOT NULL,
    `phone_number` VARCHAR(30) NOT NULL,
    `website_url` VARCHAR(255) NOT NULL,
    `document_deed_url` VARCHAR(255) NULL,
    `status` ENUM('Pending', 'Verified', 'Approved', 'Rejected') DEFAULT 'Pending',
    `admin_note` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==============================================================================
-- 10. TABLE: SYSTEM_SETTINGS (Pengaturan Portal Website)
-- ==============================================================================
CREATE TABLE `system_settings` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `setting_key` VARCHAR(100) NOT NULL UNIQUE,
    `setting_value` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==============================================================================
-- 11. TABLE: ACTIVITY_LOGS (Audit Trail Sistem)
-- ==============================================================================
CREATE TABLE `activity_logs` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT UNSIGNED NULL,
    `action` VARCHAR(100) NOT NULL,
    `description` TEXT NOT NULL,
    `ip_address` VARCHAR(45) NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_logs_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ==============================================================================
-- INITIAL SEED DATA (DATA AWAL UNTUK TESTING)
-- ==============================================================================

-- Seed Roles
INSERT INTO `roles` (`id`, `name`, `display_name`, `description`) VALUES
(1, 'super_admin', 'Super Administrator', 'Akses penuh seluruh fitur dan manajemen sistem'),
(2, 'admin', 'Admin Organisasi', 'Mengelola data organisasi, anggota, pengurus, dan agenda'),
(3, 'editor', 'Editor Redaksi', 'Mengelola publikasi berita, kategori, dan galeri');

-- Seed Default Users (Password Hash: 'admin123' bcrypt: $2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi)
INSERT INTO `users` (`id`, `role_id`, `name`, `email`, `password`, `status`) VALUES
(1, 1, 'Super Admin SMSI', 'admin@smsikepri.or.id', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Active'),
(2, 2, 'Humas Kepri', 'humas@smsikepri.or.id', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Active'),
(3, 3, 'Editor Redaksi', 'editor@smsikepri.or.id', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Active');

-- Seed Categories
INSERT INTO `categories` (`id`, `name`, `slug`, `description`) VALUES
(1, 'Pelantikan', 'pelantikan', 'Berita seremonial pelantikan pengurus SMSI'),
(2, 'Workshop & Pelatihan', 'workshop', 'Kegiatan peningkatan SDM pers dan wartawan'),
(3, 'Rakerda', 'rakerda', 'Rapat Kerja Daerah SMSI Kepulauan Riau'),
(4, 'Siaran Pers', 'siaran-pers', 'Pernyataan resmi pengurus SMSI Kepri');

-- Seed Media Members
INSERT INTO `media_members` (`id`, `registration_number`, `company_name`, `media_name`, `leader_name`, `editor_in_chief`, `regency_city`, `address`, `website_url`, `official_email`, `phone_number`, `joined_year`, `status`, `logo_url`, `description`) VALUES
(1, 'SMSI-KEPRI-001', 'PT Batam News Media', 'BatamNews.co.id', 'Muhammad Zuhri', 'Yusfreyendi', 'Batam', 'Kawasan Jasa Batam Center, Kota Batam', 'https://www.batamnews.co.id', 'redaksi@batamnews.co.id', '0778-412398', 2018, 'Terverifikasi Dewan Pers', 'https://placehold.co/200x80/102B49/FFFFFF?text=BatamNews', 'Portal berita terdepan menyajikan kabar seputar Batam, Kepri, Nasional dan Internasional.'),
(2, 'SMSI-KEPRI-002', 'PT Kepri News Siber', 'KepriNews.co', 'Rinaldi Samjaya', 'Zulhafiz', 'Tanjungpinang', 'Jl. Bintan Center No. 8, Tanjungpinang', 'https://www.keprinews.co', 'redaksi@keprinews.co', '0771-33291', 2019, 'Terverifikasi Dewan Pers', 'https://placehold.co/200x80/155EAA/FFFFFF?text=KepriNews', 'Media rujukan berita politik, ekonomi, dan pemerintahan di Provinsi Kepulauan Riau.'),
(3, 'SMSI-KEPRI-003', 'PT Karimun Media Siber', 'KarimunToday.com', 'Syahrul Nizam', 'Budi Utomo', 'Karimun', 'Jl. Nusantara No. 45, Tanjung Balai Karimun', 'https://www.karimuntoday.com', 'info@karimuntoday.com', '0777-21900', 2020, 'Anggota Aktif SMSI', 'https://placehold.co/200x80/D6A84F/102B49?text=KarimunToday', 'Menyajikan warta terkini seputar Kabupaten Karimun dan sekitarnya.'),
(4, 'SMSI-KEPRI-004', 'PT Natuna Gerbang Media', 'NatunaSiber.com', 'Doni Harvester', 'Wan Fahmi', 'Natuna', 'Ranai, Kabupaten Natuna', 'https://www.natunasiber.com', 'redaksi@natunasiber.com', '0852-6411-9988', 2020, 'Terverifikasi Dewan Pers', 'https://placehold.co/200x80/102B49/FFFFFF?text=NatunaSiber', 'Suara perbatasan Ranai Natuna mengabarkan ke pelosok perbatasan NKRI.');

-- Seed News Articles
INSERT INTO `news_articles` (`id`, `category_id`, `user_id`, `title`, `slug`, `thumbnail`, `summary`, `content`, `author_name`, `status`) VALUES
(1, 1, 1, 'Pengurus SMSI Kepri Periode Baru Resmi Dilantik, Siap Perkuat Ekosistem Digital Kepri', 'pengurus-smsi-kepri-periode-baru-resmi-dilantik', 'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?auto=format&fit=crop&w=800&q=80', 'Pelantikan jajaran pengurus Serikat Media Siber Indonesia (SMSI) Provinsi Kepulauan Riau berlangsung hikmat di Batam.', '<p>Pelantikan jajaran pengurus Serikat Media Siber Indonesia (SMSI) Provinsi Kepulauan Riau periode baru resmi digelar dengan megah di Kota Batam.</p>', 'Redaksi SMSI Kepri', 'Published'),
(2, 2, 1, 'SMSI Kepri Gelar Workshop Verifikasi Perusahaan Pers Bareng Dewan Pers', 'smsi-kepri-gelar-workshop-verifikasi-perusahaan-pers', 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=800&q=80', 'Guna mempercepat proses verifikasi administratif dan faktual, SMSI Kepri mengadakan pendampingan teknis.', '<p>Sebagai bagian dari komitmen penyehatan industri pers di daerah, SMSI Provinsi Kepulauan Riau menggelar Workshop Pendampingan Verifikasi Perusahaan Pers.</p>', 'Admin Humas', 'Published');

-- Seed Officers
INSERT INTO `officers` (`id`, `name`, `role_position`, `division`, `regency_city`, `period`, `photo_url`, `display_order`) VALUES
(1, 'Rinaldi Samjaya', 'Ketua Umum SMSI Kepri', 'Pengurus Harian', 'Provinsi', '2024 - 2029', 'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=300&q=80', 1),
(2, 'Zulhafiz, S.Kom.', 'Sekretaris Jenderal', 'Pengurus Harian', 'Provinsi', '2024 - 2029', 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=300&q=80', 2),
(3, 'Siti Maryam, S.E.', 'Bendahara Umum', 'Pengurus Harian', 'Provinsi', '2024 - 2029', 'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=300&q=80', 3);

-- Seed System Settings
INSERT INTO `system_settings` (`setting_key`, `setting_value`) VALUES
('organization_name', 'Serikat Media Siber Indonesia Provinsi Kepulauan Riau'),
('organization_short_name', 'SMSI KEPRI'),
('tagline', 'Membangun Ekosistem Media Siber yang Profesional dan Berintegritas.'),
('email_contact', 'sekretariat@smsikepri.or.id'),
('phone_contact', '+62 811-7001-928'),
('office_address', 'Gedung Pers Kepri, Jl. Engku Putri No. 12, Batam Center, Kota Batam - 29432');