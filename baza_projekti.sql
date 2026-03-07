-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.4.32-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.15.0.7171
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for imdtb_2025202590
CREATE DATABASE IF NOT EXISTS `imdtb_2025202590` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;
USE `imdtb_2025202590`;

-- Dumping structure for table imdtb_2025202590.angazovanje
CREATE TABLE IF NOT EXISTS `angazovanje` (
  `angazovanje_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `zaposleni_id` int(10) unsigned NOT NULL,
  `projekat_id` int(10) unsigned NOT NULL,
  `angazovan_at` datetime NOT NULL,
  PRIMARY KEY (`angazovanje_id`),
  KEY `fk_angazovanje_projekat_id` (`projekat_id`),
  KEY `fk_angazovanje_zaposleni_id` (`zaposleni_id`),
  CONSTRAINT `fk_angazovanje_projekat_id` FOREIGN KEY (`projekat_id`) REFERENCES `projekat` (`projekat_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_angazovanje_zaposleni_id` FOREIGN KEY (`zaposleni_id`) REFERENCES `zaposleni` (`zaposleni_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.

-- Dumping structure for table imdtb_2025202590.posao
CREATE TABLE IF NOT EXISTS `posao` (
  `posao_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `zaposleni_id` int(10) unsigned NOT NULL,
  `projekat_id` int(10) unsigned NOT NULL,
  `naziv` varchar(50) NOT NULL,
  `opis` text NOT NULL,
  `pocetak_at` datetime NOT NULL DEFAULT current_timestamp(),
  `zavrsetak_at` datetime DEFAULT NULL,
  PRIMARY KEY (`posao_id`),
  KEY `fk_posao_projekat_id` (`projekat_id`),
  KEY `fk_posao_zaposleni_id` (`zaposleni_id`),
  CONSTRAINT `fk_posao_projekat_id` FOREIGN KEY (`projekat_id`) REFERENCES `projekat` (`projekat_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_posao_zaposleni_id` FOREIGN KEY (`zaposleni_id`) REFERENCES `zaposleni` (`zaposleni_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.

-- Dumping structure for table imdtb_2025202590.projekat
CREATE TABLE IF NOT EXISTS `projekat` (
  `projekat_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `naziv` varchar(50) NOT NULL,
  `opis` text NOT NULL,
  `jedinstvena_oznaka` varchar(9) NOT NULL,
  `cena_sata_rada` decimal(10,2) NOT NULL,
  `pocetak_at` datetime NOT NULL DEFAULT current_timestamp(),
  `zavrsetak_at` datetime DEFAULT NULL,
  PRIMARY KEY (`projekat_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.

-- Dumping structure for view imdtb_2025202590.view_zarada
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `view_zarada` (
	`angazovanje_id` INT(10) UNSIGNED NOT NULL,
	`zaposleni_id` INT(10) UNSIGNED NOT NULL,
	`projekat_id` INT(10) UNSIGNED NOT NULL,
	`angazovan_at` DATETIME NOT NULL
);

-- Dumping structure for function imdtb_2025202590.www
DELIMITER //
CREATE FUNCTION `www`(`arg_korisnicko_ime` VARCHAR(50),
	`arg_sifra_projekta` VARCHAR(9)
) RETURNS decimal(10,2)
    DETERMINISTIC
BEGIN

	-- Procedura ili funkcija treba da omogući da njenim pozivom korisnik ili informacioni sistem dobije informaciju o tome koliko je ukupno novca zaradio određeni zaposleni za obavljene poslove na određenom projektu. 
	-- Zaposlenog identifikovati na osnovu datog korisničkog imena, a projekat na osnovu oznake projekta. (zaposleni -> korisnicko ime)
	-- Zarada se računa na osnovu satnice rada na projektu i ukupnog broja sati koje je zaposleni evidentirao kroz poslove na tom projektu. 
	-- Ako nije radio, vratiti iznos 0.

	-- Variables declaration

	DECLARE var_cena_sata INT;
	DECLARE var_sati_rada_total INT;
	DECLARE var_zarada DECIMAL(10,2);
	DECLARE var_zaposleni_id INT;
	DECLARE var_projekat_oznaka VARCHAR(9);

	-- Validation #1 - Check if desired user exist

	SET var_zaposleni_id = (
		SELECT z.zaposleni_id
		FROM zaposleni z
		WHERE z.korisnicko_ime = arg_korisnicko_ime

	);

	IF var_zaposleni_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT='User does not exist.';
	END IF;

	-- Validation #2 - Check if project exist

	SET var_projekat_oznaka = (
		SELECT p.jedinstvena_oznaka
		FROM projekat p
		WHERE p.jedinstvena_oznaka = arg_projekat_oznaka
	);

	IF var_projekat_oznaka IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT='Project does not exist.';
	END IF;

	-- fetch cena_sata from project

	SET var_cena_sata = (
		SELECT p.cena_sata_rada
		FROM projekat p
		WHERE p.jedinstvena_oznaka = var_projekat_oznaka
	);

	-- fetch total hours from job

	SET var_sati_rada_total = (
		SELECT 
			SUM(IFNULL(TIMESTAMPDIFF(HOUR, p.pocetak_at, p.zavrsetak_at), 0))
		FROM 
			posao p
		LEFT JOIN projekat pr ON pr.projekat_id = p.projekat_id
		WHERE pr.jedinstvena_oznaka = var_projekat_oznaka 
		AND p.zaposleni_id = var_zaposleni_id
	);

	-- hours × hourly rate, If total hours is NULL or 0 → return 0

	SET var_zarada = var_sati_rada_total * var_cena_sata;
	
	IF var_sati_rada_total IS NULL OR var_sati_rada_total = 0 THEN
		RETURN 0;
	END IF;
	
	RETURN var_zarada;
END//
DELIMITER ;

-- Dumping structure for table imdtb_2025202590.zaposleni
CREATE TABLE IF NOT EXISTS `zaposleni` (
  `zaposleni_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `korisnicko_ime` varchar(50) NOT NULL,
  `lozinka_hash` varchar(255) NOT NULL,
  PRIMARY KEY (`zaposleni_id`),
  UNIQUE KEY `uq_zaposleni_korisnicko_ime` (`korisnicko_ime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.

-- Dumping structure for trigger imdtb_2025202590.trigger_angazovanje_bi
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trigger_angazovanje_bi` BEFORE INSERT ON `angazovanje` FOR EACH ROW BEGIN
    DECLARE var_zavrsetak_projekta_at DATETIME;
    
    SET var_zavrsetak_projekta_at = (
        SELECT p.zavrsetak_at
        FROM projekat p
        WHERE p.projekat_id = NEW.projekat_id
    );

    IF NEW.angazovan_at > var_zavrsetak_projekta_at THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Angažovanje zaposlenog ne sme da počne nakon vremena završetka projekta.';
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger imdtb_2025202590.trigger_posao_bi
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trigger_posao_bi` BEFORE INSERT ON `posao` FOR EACH ROW BEGIN
    DECLARE var_zavrsetak_projekta_at DATETIME;
    
    SET var_zavrsetak_projekta_at = (
        SELECT p.zavrsetak_at
        FROM projekat p
        WHERE p.projekat_id = NEW.projekat_id
    );

    IF NEW.zavrsetak_at > var_zavrsetak_projekta_at THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Vreme završetka posla ne sme da bude nakon vremena kraja projekta za koji je taj posao evidentiran.';
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger imdtb_2025202590.trigger_projekat_bi_1
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trigger_projekat_bi_1` BEFORE INSERT ON `projekat` FOR EACH ROW BEGIN

	-- Trajanje projekta ne sme da bude kraće od dva dana. VALIDACIJA(TRIGGER)
	
    IF DATEDIFF(NEW.zavrsetak_at, NEW.pocetak_at) < 2 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Trajanje projekta ne sme da bude kraće od dva dana.';
    END IF;
    
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger imdtb_2025202590.trigger_projekat_bi_2
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trigger_projekat_bi_2` BEFORE INSERT ON `projekat` FOR EACH ROW BEGIN
	-- Oznaka projekta sadrži tri slova, četiri cifara i dva slova u svom sadržaju -- Ne može biti ni jednog drugog formata. VALIDACIJA (TRIGGER) 
	
	IF NEW.jedinstvena_oznaka NOT RLIKE '^[A-Za-z]{3}[0-9]{4}[A-Za-z]{2}$' THEN 
		SIGNAL SQLSTATE '50001' 
			SET MESSAGE_TEXT = 'Oznaka nije u dobrom formatu! Oznaka projekta mora da sadrži tri slova, četiri cifara i dva slova u svom sadržaju.'; 
	END IF;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `view_zarada`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `view_zarada` AS SELECT *
FROM angazovanje a 

-- Pogled treba da prikaže spisak projekata koji su u toku (počeli su, a nisu još završeni). 
-- Za svaki projekat treba prikazati broj zaposlenih koji su na njemu angažovani, kao i zbir trajanja svih poslova evidentiranih za taj projekat. 
-- Listu sortirati po vremenu završetka, tako da oni koji će se najskorije završiti budu vrhu. 
-- Ako nije angažovan ni jedan zaposleni, prikazati broj 0 (nula), a ne NULL. Ako za projekat nije evidentiran ni jedan posao, takođe prikazati broj 0 (nula), a ne simbol NULL. 
;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
