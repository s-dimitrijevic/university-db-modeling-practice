-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.4.32-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.14.0.7165
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for agent_prodaja_final
CREATE DATABASE IF NOT EXISTS `agent_prodaja_final` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `agent_prodaja_final`;

-- Dumping structure for table agent_prodaja_final.agent
CREATE TABLE IF NOT EXISTS `agent` (
  `agent_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `departman_id` int(10) unsigned NOT NULL,
  `korisnicko_ime` varchar(20) NOT NULL,
  `lozinka_hash` varchar(255) NOT NULL,
  `ime` varchar(50) NOT NULL,
  `prezime` varchar(50) NOT NULL,
  PRIMARY KEY (`agent_id`),
  UNIQUE KEY `uq_agent_korisnicko_ime` (`korisnicko_ime`),
  KEY `fk_agent_departman_id` (`departman_id`),
  CONSTRAINT `fk_agent_departman_id` FOREIGN KEY (`departman_id`) REFERENCES `departman` (`departman_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table agent_prodaja_final.agent: ~0 rows (approximately)
DELETE FROM `agent`;

-- Dumping structure for table agent_prodaja_final.departman
CREATE TABLE IF NOT EXISTS `departman` (
  `departman_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `puno_ime` varchar(50) NOT NULL,
  `sifra` varchar(6) NOT NULL,
  PRIMARY KEY (`departman_id`),
  UNIQUE KEY `uq_departman_sifra` (`sifra`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table agent_prodaja_final.departman: ~0 rows (approximately)
DELETE FROM `departman`;

-- Dumping structure for table agent_prodaja_final.prodaja
CREATE TABLE IF NOT EXISTS `prodaja` (
  `prodaja_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `agent_id` int(10) unsigned NOT NULL,
  `naziv_firme` varchar(50) NOT NULL,
  `prodato_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`prodaja_id`),
  KEY `fk_prodaja_agent_id` (`agent_id`),
  CONSTRAINT `fk_prodaja_agent_id` FOREIGN KEY (`agent_id`) REFERENCES `agent` (`agent_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table agent_prodaja_final.prodaja: ~0 rows (approximately)
DELETE FROM `prodaja`;

-- Dumping structure for table agent_prodaja_final.roba
CREATE TABLE IF NOT EXISTS `roba` (
  `roba_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `departman_id` int(10) unsigned NOT NULL,
  `naziv` varchar(50) NOT NULL,
  `opis` text NOT NULL,
  `cena` decimal(10,2) NOT NULL,
  `sifra` varchar(16) NOT NULL,
  PRIMARY KEY (`roba_id`),
  UNIQUE KEY `uq_roba_sifra` (`sifra`),
  KEY `fk_roba_departman_id` (`departman_id`),
  CONSTRAINT `fk_roba_departman_id` FOREIGN KEY (`departman_id`) REFERENCES `departman` (`departman_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table agent_prodaja_final.roba: ~0 rows (approximately)
DELETE FROM `roba`;

-- Dumping structure for table agent_prodaja_final.stavke_prodaje
CREATE TABLE IF NOT EXISTS `stavke_prodaje` (
  `stavke_prodaje_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `roba_id` int(10) unsigned NOT NULL,
  `prodaja_id` int(10) unsigned NOT NULL,
  `kolicina` int(11) NOT NULL,
  PRIMARY KEY (`stavke_prodaje_id`) USING BTREE,
  KEY `fk_stavke_prodaje_prodaja_id` (`prodaja_id`),
  KEY `fk_stavke_prodaje_roba_id` (`roba_id`),
  CONSTRAINT `fk_stavke_prodaje_prodaja_id` FOREIGN KEY (`prodaja_id`) REFERENCES `prodaja` (`prodaja_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_stavke_prodaje_roba_id` FOREIGN KEY (`roba_id`) REFERENCES `roba` (`roba_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table agent_prodaja_final.stavke_prodaje: ~0 rows (approximately)
DELETE FROM `stavke_prodaje`;

-- Dumping structure for trigger agent_prodaja_final.trigger_prodaja_bi
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trigger_prodaja_bi` BEFORE INSERT ON `prodaja` FOR EACH ROW -- Prodaja: Treba sprečiti agenta da evidentira prodaju robe koja ne pripada njegovom departmanu.

BEGIN
	-- treba mi agent.depart == roba.departman_id
	DECLARE var_department_robe_id INT;
	
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger agent_prodaja_final.trigger_proizvod_bi
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trigger_proizvod_bi` BEFORE INSERT ON `roba` FOR EACH ROW -- Šifra proizvoda mora da počinje isto kao i šifra departmana koji tu robu proizvodi, 
-- a dodatno sadrži još do 10 karaktera (cifra ili slova od A do Z). 

BEGIN
	DECLARE sifra_departmana VARCHAR(6);
	
	-- ovde se nalazi SIFRA departmana od 6 karaktera
	SET sifra_departmana = (
		SELECT d.sifra
		FROM departman d
		WHERE d.departman_id = NEW.departman_id
	);
	
	IF NOT (
				substring(NEW.sifra,1,6) = sifra_departmana 
				AND NEW.sifra RLIKE '^[A-Za-z0-9]{6}[A-Za-z0-9]{0,10}$' 
		) THEN
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT='Šifra proizvoda mora da počinje isto kao i šifra departmana koji tu robu proizvodi';
	END IF;
	
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;


-- Dumping database structure for b_2025202590
CREATE DATABASE IF NOT EXISTS `b_2025202590` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;
USE `b_2025202590`;

-- Dumping structure for procedure b_2025202590.Deposit
DELIMITER //
CREATE PROCEDURE `Deposit`(
	IN `in_account_number` VARCHAR(25),
	IN `in_amount` DECIMAL(10,2),
	OUT `out_error` INT
)
BEGIN

	DECLARE var_account_id INT;
	
	SET var_account_id = getAccountID(in_account_number);
	
	IF var_account_id IS NULL THEN
		SET out_error = 2;
	ELSE 
		IF in_amount <= 0 THEN
			SET out_error = 1;
		ELSE
			INSERT transakcija
			SET 
				transakcija.racun_id = in_account_number,
				transakcija.tip_transakcije_id = 1,
				transakcija.iznos = in_amount;
			SET out_error = 0;
		END IF;
	END IF;
	
END//
DELIMITER ;

-- Dumping structure for function b_2025202590.getAccountID
DELIMITER //
CREATE FUNCTION `getAccountID`(`arg_account_number` INT
) RETURNS int(11)
    DETERMINISTIC
BEGIN
	
	DECLARE var_account_id INT;
	
	SET var_account_id = (
		SELECT racun.racun_id
		FROM racun
		WHERE racun.racun_id = var_account_id AND racun.is_active = 1
	);
	
	RETURN var_account_id;
	
END//
DELIMITER ;

-- Dumping structure for function b_2025202590.GetSaldo
DELIMITER //
CREATE FUNCTION `GetSaldo`(`arg_account_number` VARCHAR(25)
) RETURNS decimal(10,0)
    DETERMINISTIC
BEGIN

	DECLARE var_account_id INT;
	SET var_account_id = getAccountID(arg_account_number);
	RETURN getTransactionSum('in') - getTransactionSum('out');
	
END//
DELIMITER ;

-- Dumping structure for function b_2025202590.getTransactionSum
DELIMITER //
CREATE FUNCTION `getTransactionSum`(`arg_account_number` INT,
	`arg_transaction_type` ENUM('in','out')
) RETURNS int(11)
    DETERMINISTIC
BEGIN
	RETURN(
		SELECT IFNULL(SUM(transakcija.iznos), 0)
		FROM transakcija
		INNER JOIN tip_transakcije ON transakcija.tip_transakcije_id = tip_transakcije.tip_transakcije_id
		WHERE tip_transakcije.vrsta = arg_transaction_type
	);
END//
DELIMITER ;

-- Dumping structure for table b_2025202590.racun
CREATE TABLE IF NOT EXISTS `racun` (
  `racun_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `broj_racuna` varchar(20) NOT NULL,
  `is_active` tinyint(1) unsigned NOT NULL,
  PRIMARY KEY (`racun_id`),
  UNIQUE KEY `uq_racun_broj_racuna` (`broj_racuna`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table b_2025202590.racun: ~0 rows (approximately)
DELETE FROM `racun`;

-- Dumping structure for table b_2025202590.tip_transakcije
CREATE TABLE IF NOT EXISTS `tip_transakcije` (
  `tip_transakcije_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `naziv` varchar(50) NOT NULL,
  `vrsta` enum('IN','OUT') NOT NULL,
  PRIMARY KEY (`tip_transakcije_id`),
  UNIQUE KEY `uq_tip_transakcije_naziv` (`naziv`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table b_2025202590.tip_transakcije: ~4 rows (approximately)
DELETE FROM `tip_transakcije`;
INSERT INTO `tip_transakcije` (`tip_transakcije_id`, `naziv`, `vrsta`) VALUES
	(1, 'zarada', 'IN'),
	(2, 'honorar', 'IN'),
	(3, 'placanje_racuna', 'OUT'),
	(4, 'prenos_ulazni', 'IN'),
	(5, 'prenos_izlazni', 'OUT');

-- Dumping structure for table b_2025202590.transakcija
CREATE TABLE IF NOT EXISTS `transakcija` (
  `transakcija_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `racun_id` int(11) unsigned NOT NULL,
  `tip_transakcije_id` int(11) unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `iznos` decimal(20,2) unsigned DEFAULT NULL,
  PRIMARY KEY (`transakcija_id`),
  KEY `fk_transakcija_racun_id` (`racun_id`),
  KEY `fk_transakcija_tip_transakcije_id` (`tip_transakcije_id`),
  CONSTRAINT `fk_transakcija_racun_id` FOREIGN KEY (`racun_id`) REFERENCES `racun` (`racun_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_transakcija_tip_transakcije_id` FOREIGN KEY (`tip_transakcije_id`) REFERENCES `tip_transakcije` (`tip_transakcije_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table b_2025202590.transakcija: ~0 rows (approximately)
DELETE FROM `transakcija`;

-- Dumping structure for procedure b_2025202590.Transfer
DELIMITER //
CREATE PROCEDURE `Transfer`(
	IN `in_from_account_number` VARCHAR(25),
	IN `in_to_account_number` VARCHAR(25),
	IN `in_amount` DECIMAL(20,2),
	OUT `out_error` INT
)
    DETERMINISTIC
label_transfer: 

BEGIN
	START TRANSACTION;
	
	CALL Withdraw(in_from_account_number, in_amount, @err);
	
	IF @err != 0 THEN
		ROLLBACK;
		SET out_error = 10 + @err;
		LEAVE label_transfer;
	END IF;
	
	CALL Deposit(in_to_account_number, in_amount, @err);
	
	IF @err != 0 THEN
		ROLLBACK;
		SET out_error = 20 + @err;
		LEAVE label_transfer;
	END IF;
	
	COMMIT;
END//
DELIMITER ;

-- Dumping structure for procedure b_2025202590.Withdraw
DELIMITER //
CREATE PROCEDURE `Withdraw`(
	IN `in_account_number` VARCHAR(25),
	IN `in_amount` DECIMAL(10,2),
	OUT `out_error` INT
)
label_withdraw_body: BEGIN
	
	-- Set account id
	
	DECLARE var_account_id INT;
	
	SET var_account_id = getAccountID(in_account_number);
	
	-- Check if account id is valid
	
	IF var_account_id IS NULL THEN
		SET out_error = 2;
		LEAVE label_withdraw_body;
	END IF;
	
	-- Check if amount is valid
	
	IF in_amount <= 0 THEN
		SET out_error = 1;
		LEAVE label_withdraw_body;
	END IF;
	
	-- Make transaction
	
	INSERT transakcija
		SET 
			transakcija.racun_id = in_account_number,
			transakcija.tip_transakcije_id = 5,
			transakcija.iznos = in_amount;
		SET out_error = 0;
		
END//
DELIMITER ;


-- Dumping database structure for baza_aukcija
CREATE DATABASE IF NOT EXISTS `baza_aukcija` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;
USE `baza_aukcija`;

-- Dumping structure for table baza_aukcija.auction
CREATE TABLE IF NOT EXISTS `auction` (
  `auction_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `category_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `title` varchar(128) NOT NULL,
  `image_path` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `starting_price` decimal(10,2) unsigned NOT NULL,
  `starts_at` datetime NOT NULL,
  `ends_at` datetime NOT NULL,
  `is_active` tinyint(1) unsigned NOT NULL,
  PRIMARY KEY (`auction_id`),
  UNIQUE KEY `uq_auction_image_path` (`image_path`),
  KEY `fk_auction_category_id` (`category_id`),
  KEY `fk_auction_user_id` (`user_id`),
  CONSTRAINT `fk_auction_category_id` FOREIGN KEY (`category_id`) REFERENCES `category` (`category_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_auction_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table baza_aukcija.auction: ~4 rows (approximately)
DELETE FROM `auction`;
INSERT INTO `auction` (`auction_id`, `category_id`, `user_id`, `title`, `image_path`, `description`, `starting_price`, `starts_at`, `ends_at`, `is_active`) VALUES
	(1, 1, 1, 'Slika 1', 'assets/image1.png', 'Neki opis...', 200.00, '2025-09-25 00:00:00', '2025-12-26 09:00:00', 0),
	(2, 2, 2, 'Skultura 1', 'assets/image2.png', 'Opis...', 160.12, '2025-06-16 11:26:51', '2025-07-16 11:26:58', 0),
	(3, 1, 2, 'Slika 2', 'assets/slika3.png', 'Nesto...', 78.56, '2025-12-16 11:27:29', '2026-02-16 11:27:35', 0),
	(4, 1, 3, 'Primer', 'nesto.png', 'asdasd', 56.10, '2025-10-16 11:40:42', '2025-10-26 11:40:44', 0);

-- Dumping structure for table baza_aukcija.category
CREATE TABLE IF NOT EXISTS `category` (
  `category_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `uq_category_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table baza_aukcija.category: ~2 rows (approximately)
DELETE FROM `category`;
INSERT INTO `category` (`category_id`, `name`) VALUES
	(1, 'Slike'),
	(2, 'Skulpture');

-- Dumping structure for table baza_aukcija.offer
CREATE TABLE IF NOT EXISTS `offer` (
  `offer_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `auction_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `price` decimal(10,2) unsigned NOT NULL,
  PRIMARY KEY (`offer_id`),
  KEY `fk_offer_auction_id` (`auction_id`),
  KEY `fk_offer_user_id` (`user_id`),
  CONSTRAINT `fk_offer_auction_id` FOREIGN KEY (`auction_id`) REFERENCES `auction` (`auction_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_offer_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table baza_aukcija.offer: ~4 rows (approximately)
DELETE FROM `offer`;
INSERT INTO `offer` (`offer_id`, `auction_id`, `user_id`, `price`) VALUES
	(1, 1, 2, 500.00),
	(2, 1, 3, 541.45),
	(3, 2, 1, 341.00),
	(4, 1, 2, 600.00);

-- Dumping structure for table baza_aukcija.user
CREATE TABLE IF NOT EXISTS `user` (
  `user_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(32) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `phone` varchar(25) NOT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uq_user_username` (`username`),
  UNIQUE KEY `uq_user_phone` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table baza_aukcija.user: ~3 rows (approximately)
DELETE FROM `user`;
INSERT INTO `user` (`user_id`, `username`, `password_hash`, `phone`) VALUES
	(1, 'avidakovic', '###', '1234567'),
	(2, 'pperic', '###', '7654321'),
	(3, 'mmarkovic', '###', '2345678');

-- Dumping structure for view baza_aukcija.view_kandidati_za_stopiranje
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `view_kandidati_za_stopiranje` (
	`auction_id` INT(10) UNSIGNED NOT NULL,
	`category_id` INT(10) UNSIGNED NOT NULL,
	`user_id` INT(10) UNSIGNED NOT NULL,
	`title` VARCHAR(1) NOT NULL COLLATE 'utf8_unicode_ci',
	`image_path` VARCHAR(1) NOT NULL COLLATE 'utf8_unicode_ci',
	`description` TEXT NOT NULL COLLATE 'utf8_unicode_ci',
	`starting_price` DECIMAL(10,2) UNSIGNED NOT NULL,
	`starts_at` DATETIME NOT NULL,
	`ends_at` DATETIME NOT NULL,
	`is_active` TINYINT(1) UNSIGNED NOT NULL,
	`offer_count` BIGINT(21) NOT NULL
);

-- Dumping structure for trigger baza_aukcija.trigger_auction_bu
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trigger_auction_bu` BEFORE UPDATE ON `auction` FOR EACH ROW BEGIN
	DECLARE broj_licitacija INT;
	
	SET broj_licitacija = (
		SELECT COUNT(offer.offer_id)
		FROM offer
		WHERE offer.auction_id = OLD.auction_id
	);
	
	IF broj_licitacija > 0 THEN
		SIGNAL SQLSTATE '50004' SET MESSAGE_TEXT = 'Ne mozemo menjati aukciju koja ima barem jednu licitaciju.';
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger baza_aukcija.trigger_auction_bu_practice
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trigger_auction_bu_practice` BEFORE UPDATE ON `auction` FOR EACH ROW BEGIN

	DECLARE broj_licitacija INT;
	
	SET broj_licitacija = (
		SELECT COUNT(offer.offer_id)
		FROM offer
		WHERE offer.auction_id = OLD.auction_id
	);
	
	IF broj_licitacija > 0 THEN
		SIGNAL SQLSTATE '50004'
			SET MESSAGE_TEXT = 'Ne mozete menjati aukciju koja je zapoceta';
	END IF;
	
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger baza_aukcija.trigger_offer_bi
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trigger_offer_bi` BEFORE INSERT ON `offer` FOR EACH ROW BEGIN

	DECLARE trenutna_cena DECIMAL(10,2);
	DECLARE vlasnik_id INT;
	DECLARE max_offer_price DECIMAL(10,2);
	DECLARE auction_starts_at DATETIME;
	DECLARE auction_ends_at DATETIME;
	
	SELECT
		auction.starting_price,
		auction.user_id,
		auction.starts_at,
		auction.ends_at
	INTO
		trenutna_cena,
		vlasnik_id,
		auction_starts_at,
		auction_ends_at
	FROM
		auction
	WHERE
		auction.auction_id = NEW.auction_id;
	
	SET max_offer_price = (
		SELECT MAX(offer.price)
		FROM offer
		WHERE offer.auction_id = NEW.auction_id
	);
	
	IF max_offer_price IS NOT NULL THEN
		SET trenutna_cena = max_offer_price;
	END IF;
	
	IF NEW.price < trenutna_cena + 50 THEN
		SIGNAL SQLSTATE '50001' SET MESSAGE_TEXT = 'Nova ponuda mora da bude barem za 50 veca od prethodne najvece';
	END IF;
	
	IF NOT NOW() BETWEEN auction_starts_at AND auction_ends_at THEN
		SIGNAL SQLSTATE '50002' SET MESSAGE_TEXT = 'Mozete licitirati samo na aktivne aukcije.';
	END IF;
	
	IF NEW.user_id = vlasnik_id THEN
		SIGNAL SQLSTATE '50003' SET MESSAGE_TEXT = 'Ne mozete licitirati na sopstvenu aukciju.';
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger baza_aukcija.trigger_offer_bi_practice
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trigger_offer_bi_practice` BEFORE INSERT ON `offer` FOR EACH ROW BEGIN

	DECLARE trenutna_cena DECIMAL(10,2);
	DECLARE owner_id INT;
	DECLARE max_offer_price DECIMAL(10,2);
	DECLARE auction_starts_at DATETIME;
	DECLARE auction_ends_at DATETIME;
	
	SELECT
		auction.starting_price,
		auction.user_id,
		auction.starts_at,
		auction.ends_at
		
	INTO
		trenutna_cena,
		owner_id,
		auction_starts_at,
		auction_ends_at
		
	FROM
		auction
		
	WHERE
		auction.auction_id = NEW.auction_id;
	
	-- Find max_offer
	SET max_offer_price = (
		SELECT MAX(offer.price)
		FROM offer
		WHERE offer.auction_id = NEW.auction_id
	);
	
	IF max_offer_price IS NOT NULL THEN
		SET trenutna_cena = max_offer_price;
	END IF;
	
	-- Nova ponuda mora da bude barem za 50 veca od prethodne najvece
	IF NEW.price < trenutna_cena + 50 THEN
		SIGNAL SQLSTATE '50001' 
			SET MESSAGE_TEXT = 'Nova ponuda mora da bude barem za 50 veca od prethodne najvece';
	END IF;
	
	-- Mozete licitirati samo na aktivne aukcije.
	IF NOT NOW() BETWEEN auction_starts_at AND auction_ends_at THEN
		SIGNAL SQLSTATE '50002' 
			SET MESSAGE_TEXT = 'Mozete licitirati samo na aktivne aukcije';
	END IF;
	
	-- Ne mozete licitirati na sopstvenu aukciju.
	IF NEW.user_id = owner_id THEN
		SIGNAL SQLSTATE '50003'
			SET MESSAGE_TEXT = 'Ne mozete licitirati na sopstvenu aukciju';
	END IF;
	
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `view_kandidati_za_stopiranje`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `view_kandidati_za_stopiranje` AS SELECT 
		auction.*,
		COUNT(offer.offer_id) AS offer_count
	FROM 
		auction
		
	LEFT JOIN offer ON auction.auction_id = offer.auction_id
	WHERE 
		auction.ends_at > NOW()
		AND auction.starts_at < NOW() - INTERVAL 2 DAY
		AND auction.is_active = 1	
	GROUP BY auction.auction_id
	HAVING offer_count = 0 
;


-- Dumping database structure for baza_bioskop
CREATE DATABASE IF NOT EXISTS `baza_bioskop` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `baza_bioskop`;

-- Dumping structure for table baza_bioskop.administrator
CREATE TABLE IF NOT EXISTS `administrator` (
  `administrator_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ime` varchar(50) NOT NULL,
  `prezime` varchar(50) NOT NULL,
  PRIMARY KEY (`administrator_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_bioskop.administrator: ~0 rows (approximately)
DELETE FROM `administrator`;
INSERT INTO `administrator` (`administrator_id`, `ime`, `prezime`) VALUES
	(1, 'Sava', 'Dimitrijevic');

-- Dumping structure for table baza_bioskop.film
CREATE TABLE IF NOT EXISTS `film` (
  `film_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `zanr_id` int(11) unsigned NOT NULL,
  `naziv` varchar(50) NOT NULL,
  `opis` varchar(255) NOT NULL,
  `trajanje` int(11) unsigned NOT NULL,
  PRIMARY KEY (`film_id`),
  KEY `fk_film_zanr_id` (`zanr_id`),
  CONSTRAINT `fk_film_zanr_id` FOREIGN KEY (`zanr_id`) REFERENCES `zanr` (`zanr_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_bioskop.film: ~3 rows (approximately)
DELETE FROM `film`;
INSERT INTO `film` (`film_id`, `zanr_id`, `naziv`, `opis`, `trajanje`) VALUES
	(1, 1, 'Nemoguca Misija', 'neki opis filma', 95),
	(2, 3, 'Good Will Hunting', 'opis nekog filma', 120),
	(3, 4, 'Vrisak 7', 'opis nekog filma', 100);

-- Dumping structure for table baza_bioskop.korisnik
CREATE TABLE IF NOT EXISTS `korisnik` (
  `korisnik_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ime` varchar(50) NOT NULL,
  `prezime` varchar(50) NOT NULL,
  `korisnicko_ime` varchar(50) NOT NULL,
  `email_adresa` varchar(50) NOT NULL,
  PRIMARY KEY (`korisnik_id`),
  UNIQUE KEY `uq_korisnik_email_adresa` (`email_adresa`),
  UNIQUE KEY `uq_korisnik_korisnicko_ime` (`korisnicko_ime`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_bioskop.korisnik: ~3 rows (approximately)
DELETE FROM `korisnik`;
INSERT INTO `korisnik` (`korisnik_id`, `ime`, `prezime`, `korisnicko_ime`, `email_adresa`) VALUES
	(1, 'Marko', 'Markovic', 'MarkoMk92', 'markomarkovic@gmail.com'),
	(2, 'Petar', 'Petrovic', 'PetarP2145', 'p.petrovic@yahoo.com'),
	(3, 'Ilija', 'Milicevic', 'p.milicevic', 'ilijam@gmail.com');

-- Dumping structure for table baza_bioskop.projekcija
CREATE TABLE IF NOT EXISTS `projekcija` (
  `projekcija_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `film_id` int(10) unsigned NOT NULL,
  `sala_id` int(10) unsigned NOT NULL,
  `administrator_id` int(10) unsigned NOT NULL,
  `pocetak_at` datetime DEFAULT NULL,
  PRIMARY KEY (`projekcija_id`),
  KEY `fk_projekacija_film_id` (`film_id`),
  KEY `fk_projekcija_administrator_id` (`administrator_id`),
  KEY `fk_projekcija_sala_id` (`sala_id`),
  CONSTRAINT `fk_projekacija_film_id` FOREIGN KEY (`film_id`) REFERENCES `film` (`film_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_projekcija_administrator_id` FOREIGN KEY (`administrator_id`) REFERENCES `administrator` (`administrator_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_projekcija_sala_id` FOREIGN KEY (`sala_id`) REFERENCES `sala` (`sala_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_bioskop.projekcija: ~0 rows (approximately)
DELETE FROM `projekcija`;
INSERT INTO `projekcija` (`projekcija_id`, `film_id`, `sala_id`, `administrator_id`, `pocetak_at`) VALUES
	(4, 2, 3, 1, '2026-03-14 14:40:53'),
	(5, 1, 2, 1, '2026-03-19 15:55:23');

-- Dumping structure for table baza_bioskop.rezervacija
CREATE TABLE IF NOT EXISTS `rezervacija` (
  `rezervacija_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `korisnik_id` int(10) unsigned NOT NULL,
  `projekcija_id` int(10) unsigned NOT NULL,
  `mesto` int(10) unsigned NOT NULL,
  `red` int(10) unsigned NOT NULL,
  `napravljena_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`rezervacija_id`),
  UNIQUE KEY `uq_rezervacija_projekcija_id_mesto_red` (`projekcija_id`,`mesto`,`red`),
  KEY `fk_rezervacija_korisnik_id` (`korisnik_id`),
  CONSTRAINT `fk_rezervacija_korisnik_id` FOREIGN KEY (`korisnik_id`) REFERENCES `korisnik` (`korisnik_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_rezervacija_projekcija_id` FOREIGN KEY (`projekcija_id`) REFERENCES `projekcija` (`projekcija_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_bioskop.rezervacija: ~3 rows (approximately)
DELETE FROM `rezervacija`;
INSERT INTO `rezervacija` (`rezervacija_id`, `korisnik_id`, `projekcija_id`, `mesto`, `red`, `napravljena_at`) VALUES
	(1, 3, 4, 5, 5, '2026-03-14 16:15:52'),
	(3, 1, 5, 3, 3, '2026-03-14 16:16:08'),
	(4, 2, 4, 2, 1, '2026-03-14 16:16:25');

-- Dumping structure for table baza_bioskop.sala
CREATE TABLE IF NOT EXISTS `sala` (
  `sala_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `naziv` varchar(50) NOT NULL,
  `ukupan_broj_redova` int(10) unsigned NOT NULL,
  `broj_mesta_po_redu` int(10) unsigned NOT NULL,
  PRIMARY KEY (`sala_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_bioskop.sala: ~2 rows (approximately)
DELETE FROM `sala`;
INSERT INTO `sala` (`sala_id`, `naziv`, `ukupan_broj_redova`, `broj_mesta_po_redu`) VALUES
	(1, 'MikeLod', 25, 10),
	(2, 'Saturn4', 15, 15),
	(3, 'Lancel', 15, 25);

-- Dumping structure for view baza_bioskop.view_filmovi
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `view_filmovi` (
	`naziv_filma` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_general_ci',
	`naziv_zanra` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_general_ci',
	`ukupan_broj_buducih_projekcija` BIGINT(21) NOT NULL,
	`sala_naredne_projekcije` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_general_ci',
	`ukupan_broj_rezervisanih_mesta` BIGINT(21) NOT NULL
);

-- Dumping structure for table baza_bioskop.zanr
CREATE TABLE IF NOT EXISTS `zanr` (
  `zanr_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `naziv` varchar(50) NOT NULL,
  PRIMARY KEY (`zanr_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_bioskop.zanr: ~6 rows (approximately)
DELETE FROM `zanr`;
INSERT INTO `zanr` (`zanr_id`, `naziv`) VALUES
	(1, 'akcija'),
	(2, 'komedija'),
	(3, 'drama'),
	(4, 'horror'),
	(5, 'animirani'),
	(6, 'dokumentarac');

-- Dumping structure for trigger baza_bioskop.trigger_film_before_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trigger_film_before_insert` BEFORE INSERT ON `film` FOR EACH ROW -- •	Film: Trajanje filma mora biti veće od nule.

BEGIN
	IF NEW.trajanje < 0 THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT='Trajanje filma mora biti veće od nule.';
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger baza_bioskop.trigger_korisnik_before_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trigger_korisnik_before_insert` BEFORE INSERT ON `korisnik` FOR EACH ROW -- •	Korisnik: Korisničko ime se sastoji isključivo od malih slova 
-- latinice i cifara, sa dužinom između 4 i 20 karaktera. Ne može biti drugog formata.

BEGIN
	IF NEW.korisnicko_ime NOT RLIKE '^[a-z0-9]{4,20}$' THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT='Korisnik: Korisničko ime se sastoji isključivo od malih slova 
			latinice i cifara, sa dužinom između 4 i 20 karaktera. Ne može biti drugog formata.';
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger baza_bioskop.trigger_projekcija_before_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trigger_projekcija_before_insert` BEFORE INSERT ON `projekcija` FOR EACH ROW -- •	Projekcija: Nije dozvoljeno da dve projekcije u istoj sali 
-- imaju preklapajuće termine — nova projekcija ne sme da počne 
-- pre nego što prethodna projekcija u toj sali završi (trajanje 
-- filma + 30 minuta za čišćenje sale). 

BEGIN
	DECLARE postoji_konflikt INT;
	
		SELECT COUNT(*)
		INTO postoji_konflikt
		FROM projekcija p
		INNER JOIN film f ON f.film_id = p.film_id
		WHERE p.sala_id = NEW.sala_id 
		AND DATE_ADD(p.pocetak_at, INTERVAL f.trajanje + 30 MINUTE) > NEW.pocetak_at; 
	
	IF postoji_konflikt > 0 THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT='Nije dozvoljeno da dve projekcije u istoj sali imaju preklapajuće termine — nova projekcija ne sme da počne 
 									pre nego što prethodna projekcija u toj sali završi (trajanje filma + 30 minuta za čišćenje sale';
 	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger baza_bioskop.trigger_rezervacija_before_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trigger_rezervacija_before_insert` BEFORE INSERT ON `rezervacija` FOR EACH ROW -- Rezervacija: Rezervacija ne sme biti izvršena za mesto čiji broj reda 
-- ili broj mesta prelazi kapacitet sale u kojoj se projekcija održava. 

BEGIN
	DECLARE var_max_red INT;
	DECLARE var_max_mesto INT;
	
	SELECT s.ukupan_broj_redova, s.broj_mesta_po_redu
	INTO var_max_red, var_max_mesto
	FROM projekcija p
	JOIN sala s ON s.sala_id = p.sala_id
	WHERE p.projekcija_id = NEW.projekcija_id;
	
	IF NEW.red > var_max_red OR NEW.mesto > var_max_mesto THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT='Rezervacija ne sme biti izvršena za mesto čiji broj reda ili broj mesta prelazi kapacitet sale u kojoj se projekcija održava. ';
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger baza_bioskop.trigger_sala_before_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trigger_sala_before_insert` BEFORE INSERT ON `sala` FOR EACH ROW -- Sala: Broj redova i broj mesta po redu moraju biti pozitivni celi brojevi veći od nule.

BEGIN
	IF NEW.broj_mesta_po_redu AND NEW.ukupan_broj_redova < 0 THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT='Broj redova i broj mesta po redu moraju biti pozitivni celi brojevi veći od nule.';
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `view_filmovi`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `view_filmovi` AS -- Pogled treba da prikaže spisak filmova koji su raspoređeni na bar jednu buduću projekciju 
-- (tj. projekciju čije vreme početka je nakon trenutnog momenta). Za svaki takav film prikazati: 
-- naziv filma, žanr, ukupan broj budućih projekcija za taj film, naziv sale u kojoj se naredna (najbliža) 
-- projekcija tog filma odvija, kao i ukupan broj rezervisanih mesta za sve buduće projekcije tog filma. 
-- Ako za neku buduću projekciju nije rezervovano nijedno mesto, taj broj treba prikazati kao 0, a ne NULL. 
-- Listu sortirati po broju budućih projekcija opadajuće, a zatim po nazivu filma rastuće.

SELECT 
	f.naziv AS naziv_filma,
	z.naziv AS naziv_zanra,
	COUNT(DISTINCT p.projekcija_id) AS ukupan_broj_buducih_projekcija,
	s.naziv AS sala_naredne_projekcije,
	IFNULL(COUNT(r.rezervacija_id),0) AS ukupan_broj_rezervisanih_mesta
	
FROM film f
	
JOIN projekcija p ON p.film_id = f.film_id	
JOIN zanr z ON z.zanr_id = f.zanr_id	
JOIN sala s ON s.sala_id = p.sala_id	
LEFT JOIN rezervacija r ON r.projekcija_id = p.projekcija_id

WHERE p.pocetak_at > NOW() 

GROUP BY f.film_id

ORDER BY 
	ukupan_broj_buducih_projekcija DESC,
	f.naziv ASC 
;


-- Dumping database structure for baza_bolnica
CREATE DATABASE IF NOT EXISTS `baza_bolnica` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `baza_bolnica`;

-- Dumping structure for table baza_bolnica.dijagnoza
CREATE TABLE IF NOT EXISTS `dijagnoza` (
  `dijagnoza_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `mkb_sifra` varchar(10) NOT NULL,
  `naziv` varchar(50) NOT NULL,
  `napomena_lekara` text NOT NULL,
  `dijagnozirano_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`dijagnoza_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_bolnica.dijagnoza: ~2 rows (approximately)
DELETE FROM `dijagnoza`;
INSERT INTO `dijagnoza` (`dijagnoza_id`, `mkb_sifra`, `naziv`, `napomena_lekara`, `dijagnozirano_at`) VALUES
	(1, '1234123', 'arteroskleroza', '', '2026-03-11 15:32:10'),
	(2, '523412', 'kancer', '', '2026-03-11 15:32:28');

-- Dumping structure for table baza_bolnica.evidencija
CREATE TABLE IF NOT EXISTS `evidencija` (
  `evidencija_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `hospitalizacija_id` int(10) unsigned NOT NULL,
  `lekar_id` int(10) unsigned NOT NULL,
  `dijagnoza_id` int(10) unsigned NOT NULL,
  `napomena` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`evidencija_id`),
  KEY `fk_lekar_hospitalizacija_id` (`hospitalizacija_id`),
  KEY `fk_evidencija_lekar_id` (`lekar_id`),
  KEY `fk_dijagnoza_id` (`dijagnoza_id`),
  CONSTRAINT `fk_dijagnoza_id` FOREIGN KEY (`dijagnoza_id`) REFERENCES `dijagnoza` (`dijagnoza_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_evidencija_lekar_id` FOREIGN KEY (`lekar_id`) REFERENCES `lekar` (`lekar_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_lekar_hospitalizacija_id` FOREIGN KEY (`hospitalizacija_id`) REFERENCES `hospitalizacija` (`hospitalizacija_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_bolnica.evidencija: ~0 rows (approximately)
DELETE FROM `evidencija`;
INSERT INTO `evidencija` (`evidencija_id`, `hospitalizacija_id`, `lekar_id`, `dijagnoza_id`, `napomena`) VALUES
	(1, 2, 1, 2, NULL);

-- Dumping structure for function baza_bolnica.find_total_diagnosis
DELIMITER //
CREATE FUNCTION `find_total_diagnosis`(`arg_pacijent_id` INT,
	`arg_mkb_sifra` VARCHAR(50)
) RETURNS int(11)
    DETERMINISTIC
BEGIN
	-- Procedura ili funkcija treba da omogući da njenim pozivom korisnik 
	-- ili informacioni sistem dobije informaciju o tome koliko je različitih 
	-- dijagnoza (po MKB šifri) postavljeno određenom pacijentu tokom celokupne 
	-- istorije njegovih hospitalizacija. 
	
	DECLARE var_pacijent_id INT;
	DECLARE var_mkb_sifra INT;
	DECLARE var_totalno_diajagnoza INT;

	-- Validacija pacijent_ID
	SET var_pacijent_id = (
				SELECT p.pacijent_id
				FROM pacijent p
				WHERE p.pacijent_id = arg_pacijent_id
	);
	
	IF var_pacijent_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT='Pacijent sa navedenim ID-jem ne postoji';
	END IF;
	
	-- Validacija mkb_sifre
		SET var_mkb_sifra = (
				SELECT d.mkb_sifra
				FROM dijagnoza d
				WHERE d.mkb_sifra = arg_mkb_sifra
	);
	
	IF var_mkb_sifra IS NULL THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT='Navedena sifra ne postoji';
	END IF;
	
	-- Logika
	SET var_totalno_diajagnoza = (
		SELECT
			COUNT(DISTINCT d.mkb_sifra) 
		FROM
			evidencija e
		LEFT JOIN 
			dijagnoza d ON e.dijagnoza_id = d.dijagnoza_id
		INNER JOIN
			pacijent p ON p.pacijent_id = var_pacijent_id
		WHERE p.jmbg = arg_pacijent_jmbg
	);
	
	-- Return
	RETURN var_totalno_diajagnoza;
END//
DELIMITER ;

-- Dumping structure for table baza_bolnica.hospitalizacija
CREATE TABLE IF NOT EXISTS `hospitalizacija` (
  `hospitalizacija_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `pacijent_id` int(10) unsigned NOT NULL,
  `datum_prijema_at` datetime NOT NULL DEFAULT current_timestamp(),
  `datum_otpusta_at` datetime DEFAULT NULL,
  `naziv_odeljenja` varchar(50) NOT NULL,
  PRIMARY KEY (`hospitalizacija_id`),
  KEY `fk_hospitalizacija_pacijent_id` (`pacijent_id`),
  CONSTRAINT `fk_hospitalizacija_pacijent_id` FOREIGN KEY (`pacijent_id`) REFERENCES `pacijent` (`pacijent_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_bolnica.hospitalizacija: ~1 rows (approximately)
DELETE FROM `hospitalizacija`;
INSERT INTO `hospitalizacija` (`hospitalizacija_id`, `pacijent_id`, `datum_prijema_at`, `datum_otpusta_at`, `naziv_odeljenja`) VALUES
	(2, 1, '2026-03-11 15:30:36', NULL, 'kardiologija'),
	(5, 1, '2026-03-11 15:31:23', NULL, 'kardiologija');

-- Dumping structure for table baza_bolnica.karton
CREATE TABLE IF NOT EXISTS `karton` (
  `karton_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `lekar_id` int(10) unsigned NOT NULL,
  `jedinstveni_broj` varchar(10) NOT NULL,
  `pacijent_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`karton_id`),
  UNIQUE KEY `uq_karton_jedinstveni_broj` (`jedinstveni_broj`),
  KEY `fk_karton_lekar_id` (`lekar_id`),
  KEY `fk_karton_pacijent_id` (`pacijent_id`),
  CONSTRAINT `fk_karton_lekar_id` FOREIGN KEY (`lekar_id`) REFERENCES `lekar` (`lekar_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_karton_pacijent_id` FOREIGN KEY (`pacijent_id`) REFERENCES `pacijent` (`pacijent_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_bolnica.karton: ~1 rows (approximately)
DELETE FROM `karton`;
INSERT INTO `karton` (`karton_id`, `lekar_id`, `jedinstveni_broj`, `pacijent_id`) VALUES
	(2, 1, '9182391287', 2);

-- Dumping structure for table baza_bolnica.lekar
CREATE TABLE IF NOT EXISTS `lekar` (
  `lekar_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ime` varchar(50) NOT NULL,
  `prezime` varchar(50) NOT NULL,
  `specijalnost` varchar(50) NOT NULL,
  `broj_licence` varchar(10) NOT NULL,
  PRIMARY KEY (`lekar_id`),
  UNIQUE KEY `uq_lekar_broj_licence` (`broj_licence`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_bolnica.lekar: ~1 rows (approximately)
DELETE FROM `lekar`;
INSERT INTO `lekar` (`lekar_id`, `ime`, `prezime`, `specijalnost`, `broj_licence`) VALUES
	(1, 'Sava', 'Dimitrije', 'kardiolog', '1234567890'),
	(2, 'Marko', 'Markovic', 'endokrinolog', '9876543212');

-- Dumping structure for table baza_bolnica.pacijent
CREATE TABLE IF NOT EXISTS `pacijent` (
  `pacijent_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ime` varchar(50) NOT NULL,
  `prezime` varchar(50) NOT NULL,
  `datum_rodjenja` datetime NOT NULL,
  `jmbg` varchar(13) NOT NULL,
  PRIMARY KEY (`pacijent_id`),
  UNIQUE KEY `uq_pacijent_jmbg` (`jmbg`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_bolnica.pacijent: ~2 rows (approximately)
DELETE FROM `pacijent`;
INSERT INTO `pacijent` (`pacijent_id`, `ime`, `prezime`, `datum_rodjenja`, `jmbg`) VALUES
	(1, 'Petar', 'Petrovic', '2026-03-11 15:28:39', '0103997710146'),
	(2, 'Slavko', 'Mitrovic', '2026-03-11 15:29:05', '030997710156');

-- Dumping structure for view baza_bolnica.view_1
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `view_1` (
	`naziv_odeljenja` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_general_ci',
	`ukupno_hospitalizacija` BIGINT(21) NOT NULL,
	`ukupno_dijagnoza` BIGINT(21) NOT NULL
);

-- Dumping structure for trigger baza_bolnica.trigger_dijagnoza_bi
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trigger_dijagnoza_bi` BEFORE INSERT ON `dijagnoza` FOR EACH ROW BEGIN
	--	Dijagnoza: MKB šifra se sastoji od jednog velikog slova i dve do četiri cifre. Ne može biti drugog formata
	IF NEW.mkb_sifra NOT RLIKE '^[A-Z]{1}[0-9]{2,4}$' THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT='MKB šifra se sastoji od jednog velikog slova i dve do četiri cifre. Ne može biti drugog formata';
	END IF;
	
	-- Odlicno!
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger baza_bolnica.trigger_evidencija_bi
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trigger_evidencija_bi` BEFORE INSERT ON `evidencija` FOR EACH ROW BEGIN
	-- Evidencija: Vreme postavljanja dijagnoze ne sme biti izvan perioda trajanja hospitalizacije.
	DECLARE pocetak_hospitalizacije_at DATETIME;
	DECLARE kraj_hospitalizacije_at DATETIME;
	DECLARE dijagnoza_at DATETIME;
	
	SET pocetak_hospitalizacije_at = (
		SELECT h.datum_prijema_at
		FROM hospitalizacija h
		WHERE h.hospitalizacija_id = NEW.hospitalizacija_id
	);
	
	SET kraj_hospitalizacije_at = (
		SELECT h.datum_otpusta_at
		FROM hospitalizacija h
		WHERE h.hospitalizacija_id = NEW.hospitalizacija_id
	);
	
	SET dijagnoza_at = (
		SELECT d.dijagnozirano_at
		FROM dijagnoza d
		WHERE d.dijagnoza_id = NEW.dijagnoza_id
	);
	
	IF dijagnoza_at NOT BETWEEN pocetak_hospitalizacije_at AND kraj_hospitalizacije_at THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT='Vreme postavljanja dijagnoze ne sme biti izvan perioda trajanja hospitalizacije.';
	END IF;
	
	-- Kraj otpusta moze biti NULL, sta onda? Potrebna validacija i dodatna logika.
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger baza_bolnica.trigger_hospitalizacija_bi
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trigger_hospitalizacija_bi` BEFORE INSERT ON `hospitalizacija` FOR EACH ROW BEGIN
	-- Hospitalizacija: Datum otpusta ne sme biti pre datuma prijema.
	IF NEW.datum_otpusta_at < NEW.datum_prijema_at THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT='Datum otpusta ne sme biti pre datuma prijema.';
	END IF;
	
	-- Sta ako je datum otpusta null?
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger baza_bolnica.trigger_hospitalizacija_bi_2
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trigger_hospitalizacija_bi_2` BEFORE INSERT ON `hospitalizacija` FOR EACH ROW BEGIN
	-- Hospitalizacija: Hospitalizacija ne može početi pre datuma rođenja pacijenta.
	
	DECLARE datum_rodjenja_pacijenta DATETIME;
	SET datum_rodjenja_pacijenta = (
		SELECT p.datum_rodjenja
		FROM pacijent p
		WHERE p.pacijent_id = NEW.pacijent_id
	);
	
	IF NEW.datum_prijema_at < datum_rodjenja_pacijenta THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT='Hospitalizacija ne može početi pre datuma rođenja pacijenta.';
	END IF;
	
	-- Odlicno!
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger baza_bolnica.trigger_lekar_bi
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trigger_lekar_bi` BEFORE INSERT ON `lekar` FOR EACH ROW BEGIN
 -- Lekar: Broj licence se sastoji od dva velika slova, zatim šest cifara. Ne može biti drugog formata.
 IF NEW.broj_licence NOT RLIKE '^[A-Z]{2}[0-9]{6}$' THEN
 	SIGNAL SQLSTATE '45000'
 		SET MESSAGE_TEXT='Broj licence se sastoji od dva velika slova, zatim šest cifara. Ne može biti drugog formata.';
 END IF;
 
 -- Odlicno!
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `view_1`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `view_1` AS SELECT 
	-- Pogled treba da prikaže spisak odeljenja koja su trenutno aktivna 
	-- — ona odeljenja u kojima postoji bar jedna hospitalizacija koja je 
	-- počela, ali još nije završena (pacijent nije otpušten, tj. datum otpusta je NULL). 
	h.naziv_odeljenja,
	
	--	Za svako takvo odeljenje prikazati ukupan broj (count) trenutno hospitalizovanih pacijenata,
	IFNULL(COUNT(DISTINCT 	h.hospitalizacija_id),0) AS ukupno_hospitalizacija,
	
	-- kao i ukupan broj (count) dijagnoza evidentiranih tokom svih aktivnih hospitalizacija na tom odeljenju. 
	IFNULL(COUNT(e.dijagnoza_id),0) AS ukupno_dijagnoza

FROM 
	hospitalizacija h

LEFT JOIN evidencija e ON h.hospitalizacija_id = e.hospitalizacija_id

WHERE 
	h.datum_prijema_at IS NOT NULL 
	AND h.datum_otpusta_at IS NULL 
	
GROUP BY
	h.naziv_odeljenja
	
ORDER BY
	ukupno_dijagnoza DESC 
;


-- Dumping database structure for baza_car_rent
CREATE DATABASE IF NOT EXISTS `baza_car_rent` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `baza_car_rent`;

-- Dumping structure for table baza_car_rent.admin
CREATE TABLE IF NOT EXISTS `admin` (
  `admin_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT curtime(),
  `deleted_at` datetime DEFAULT NULL,
  `first_name` varchar(32) NOT NULL,
  `last_name` varchar(32) NOT NULL,
  `email` varchar(255) NOT NULL,
  PRIMARY KEY (`admin_id`),
  UNIQUE KEY `uq_admin_username` (`username`),
  UNIQUE KEY `uq_admin_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_car_rent.admin: ~0 rows (approximately)
DELETE FROM `admin`;

-- Dumping structure for table baza_car_rent.client
CREATE TABLE IF NOT EXISTS `client` (
  `client_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_card_number` char(50) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(10) NOT NULL,
  PRIMARY KEY (`client_id`),
  UNIQUE KEY `uq_client_email` (`email`) USING BTREE,
  UNIQUE KEY `uq_client_id_card_number` (`id_card_number`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_car_rent.client: ~0 rows (approximately)
DELETE FROM `client`;

-- Dumping structure for table baza_car_rent.manufacturer
CREATE TABLE IF NOT EXISTS `manufacturer` (
  `manufacturer_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`manufacturer_id`),
  UNIQUE KEY `uq_manufacturer_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_car_rent.manufacturer: ~0 rows (approximately)
DELETE FROM `manufacturer`;

-- Dumping structure for table baza_car_rent.model
CREATE TABLE IF NOT EXISTS `model` (
  `model_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `manufacturer_id` int(10) unsigned NOT NULL,
  `name` varchar(50) NOT NULL,
  `year` int(4) unsigned NOT NULL,
  PRIMARY KEY (`model_id`),
  UNIQUE KEY `uq_model_name_year` (`name`,`year`),
  KEY `fk_model_manufacturer_id` (`manufacturer_id`),
  CONSTRAINT `fk_model_manufacturer_id` FOREIGN KEY (`manufacturer_id`) REFERENCES `manufacturer` (`manufacturer_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_car_rent.model: ~0 rows (approximately)
DELETE FROM `model`;

-- Dumping structure for table baza_car_rent.vehicle
CREATE TABLE IF NOT EXISTS `vehicle` (
  `vehicle_id` int(10) unsigned NOT NULL,
  `model_id` int(10) unsigned NOT NULL,
  `year` smallint(4) unsigned NOT NULL DEFAULT 0,
  `engine_displacement` int(11) unsigned NOT NULL,
  `fuel_type` enum('diesel','gasoline','hybrid') NOT NULL,
  `body_type` enum('hatchback','sedan','SUV') NOT NULL,
  `registered_at` datetime NOT NULL,
  PRIMARY KEY (`vehicle_id`),
  UNIQUE KEY `uq_vehicle_engine_displacement` (`engine_displacement`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_car_rent.vehicle: ~0 rows (approximately)
DELETE FROM `vehicle`;


-- Dumping database structure for baza_fudbal
CREATE DATABASE IF NOT EXISTS `baza_fudbal` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `baza_fudbal`;

-- Dumping structure for table baza_fudbal.klub
CREATE TABLE IF NOT EXISTS `klub` (
  `klub_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `naziv` varchar(50) NOT NULL,
  `grad` varchar(50) NOT NULL,
  `godina` int(4) unsigned NOT NULL,
  `jedinstveni_kod` varchar(50) NOT NULL,
  PRIMARY KEY (`klub_id`),
  UNIQUE KEY `uq_klub_jedinstveni_kod` (`jedinstveni_kod`),
  UNIQUE KEY `uq_klub_naziv` (`naziv`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_fudbal.klub: ~3 rows (approximately)
DELETE FROM `klub`;
INSERT INTO `klub` (`klub_id`, `naziv`, `grad`, `godina`, `jedinstveni_kod`) VALUES
	(1, 'Bajern', 'Minhen', 1889, 'ABC123'),
	(2, 'Ausburg', 'Ausburg', 1995, 'CDF351'),
	(3, 'Partizan', 'Beograd', 2005, 'AHD451');

-- Dumping structure for table baza_fudbal.klub_liga
CREATE TABLE IF NOT EXISTS `klub_liga` (
  `klub_liga_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `klub_id` int(10) unsigned NOT NULL,
  `liga_id` int(10) unsigned NOT NULL,
  `sezona_id` int(11) unsigned NOT NULL,
  `datum_pristupanja` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`klub_liga_id`),
  UNIQUE KEY `uq_klub_liga_klub_id_liga_id` (`klub_id`,`liga_id`),
  KEY `fk_klub_liga_liga_id` (`liga_id`),
  KEY `fk_klub_liga_sezona_id` (`sezona_id`),
  CONSTRAINT `fk_klub_liga_klub_id` FOREIGN KEY (`klub_id`) REFERENCES `klub` (`klub_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_klub_liga_liga_id` FOREIGN KEY (`liga_id`) REFERENCES `liga` (`liga_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_klub_liga_sezona_id` FOREIGN KEY (`sezona_id`) REFERENCES `sezona` (`sezona_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_fudbal.klub_liga: ~0 rows (approximately)
DELETE FROM `klub_liga`;

-- Dumping structure for table baza_fudbal.kolo
CREATE TABLE IF NOT EXISTS `kolo` (
  `kolo_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`kolo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_fudbal.kolo: ~0 rows (approximately)
DELETE FROM `kolo`;

-- Dumping structure for table baza_fudbal.liga
CREATE TABLE IF NOT EXISTS `liga` (
  `liga_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sport_id` int(10) unsigned NOT NULL,
  `naziv` varchar(50) NOT NULL,
  `godina_osnivanja` int(4) unsigned NOT NULL,
  PRIMARY KEY (`liga_id`),
  KEY `fk_liga_sport_id` (`sport_id`) USING BTREE,
  CONSTRAINT `fk_liga_sport_id` FOREIGN KEY (`sport_id`) REFERENCES `sport` (`sport_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_fudbal.liga: ~3 rows (approximately)
DELETE FROM `liga`;
INSERT INTO `liga` (`liga_id`, `sport_id`, `naziv`, `godina_osnivanja`) VALUES
	(1, 1, 'BundesLiga', 1980),
	(2, 2, 'MozartLiga', 1999),
	(3, 1, 'JelenSuperLiga', 2005);

-- Dumping structure for table baza_fudbal.sezona
CREATE TABLE IF NOT EXISTS `sezona` (
  `sezona_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `naziv` varchar(50) NOT NULL,
  PRIMARY KEY (`sezona_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_fudbal.sezona: ~2 rows (approximately)
DELETE FROM `sezona`;
INSERT INTO `sezona` (`sezona_id`, `naziv`) VALUES
	(1, '2024/2025'),
	(2, '2023/2024'),
	(3, '2022/2023');

-- Dumping structure for table baza_fudbal.sport
CREATE TABLE IF NOT EXISTS `sport` (
  `sport_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `naziv` varchar(50) NOT NULL,
  PRIMARY KEY (`sport_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_fudbal.sport: ~4 rows (approximately)
DELETE FROM `sport`;
INSERT INTO `sport` (`sport_id`, `naziv`) VALUES
	(1, 'fudbal'),
	(2, 'kosarka'),
	(3, 'odbojka'),
	(4, 'tenis'),
	(5, 'rukomet');

-- Dumping structure for table baza_fudbal.utakmica
CREATE TABLE IF NOT EXISTS `utakmica` (
  `utakmica_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`utakmica_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_fudbal.utakmica: ~0 rows (approximately)
DELETE FROM `utakmica`;


-- Dumping database structure for baza_okidaci_vezba
CREATE DATABASE IF NOT EXISTS `baza_okidaci_vezba` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `baza_okidaci_vezba`;

-- Dumping structure for table baza_okidaci_vezba.tabelapodaci
CREATE TABLE IF NOT EXISTS `tabelapodaci` (
  `podaci_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ime` varchar(50) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '0',
  `prezime` varchar(50) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '0',
  `broj_telefona` varchar(13) NOT NULL DEFAULT '0',
  `registarska_oznaka` varchar(11) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '0',
  `kontrolni_broj_zapisa` int(10) unsigned NOT NULL DEFAULT 0,
  `datum_registracije` datetime NOT NULL,
  `broj_modela` varchar(10) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '0',
  `broj_tekuceg_racuna` varchar(20) NOT NULL DEFAULT '0',
  `stopa_poreza` decimal(4,2) unsigned NOT NULL DEFAULT 0.00,
  `adresa_elektronske_poste` varchar(50) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '0',
  `korisnicko_ime` varchar(50) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '0',
  PRIMARY KEY (`podaci_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table baza_okidaci_vezba.tabelapodaci: ~3 rows (approximately)
DELETE FROM `tabelapodaci`;
INSERT INTO `tabelapodaci` (`podaci_id`, `ime`, `prezime`, `broj_telefona`, `registarska_oznaka`, `kontrolni_broj_zapisa`, `datum_registracije`, `broj_modela`, `broj_tekuceg_racuna`, `stopa_poreza`, `adresa_elektronske_poste`, `korisnicko_ime`) VALUES
	(1, '2asdas', 'Test', '1231233', '123asdfawre', 3213213, '0000-00-00 00:00:00', '234213', '123123123', 0.02, '0asdasdasd213qwe@asd', 'asdease43'),
	(2, 'Sava', '0', '0', '0', 0, '0000-00-00 00:00:00', '0', '0', 0.00, '0', '0'),
	(3, 'Marko', '0', '0', '0', 0, '0000-00-00 00:00:00', '0', '0', 0.00, '0', '0'),
	(4, 'Petar', 'Sva', '011/63-62-523', 'BG 2138-CU', 6, '0000-00-00 00:00:00', 'RTO-12AE44', '132-91239128233-12', 0.00, 'savadimitrijevic@gmail.com', 'd-sava4');

-- Dumping structure for trigger baza_okidaci_vezba.trigger_tabelapodaci_bi
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trigger_tabelapodaci_bi` BEFORE INSERT ON `tabelapodaci` FOR EACH ROW /* Before INSERT */ 

BEGIN

	-- Validate Ime
	IF NEW.ime NOT RLIKE '^[A-Z][a-z]+( [A-Z][a-z]+)?$' THEN
		SIGNAL SQLSTATE '50001' 
		SET MESSAGE_TEXT = 'Ime nije u ispravnom formatu';
	END IF;
	
	-- Validate Prezime
	IF NEW.prezime NOT RLIKE '^[A-Z][a-z]+( [A-Z][a-z]+)?$' THEN
		SIGNAL SQLSTATE '50002' 
		SET MESSAGE_TEXT = 'Prezime nije u ispravnom formatu';
	END IF;
	
	-- Validate Phone Number
	IF NEW.broj_telefona NOT RLIKE '^0[0-9]{2}\/[0-9]{2}\-[0-9]{2}\-[0-9]{3}$' THEN
		SIGNAL SQLSTATE '50003'
		SET MESSAGE_TEXT = 'Telefon nije u ispravnom formatu';
	END IF;
	
	-- Validate License Plate
	IF NEW.registarska_oznaka NOT RLIKE '^[A-Z]{2} [0-9]{3,5}\-[A-Z]{2}$' THEN
		SIGNAL SQLSTATE '50004'
		SET MESSAGE_TEXT = 'Tablice nisu u ispravnom formatu';
	END IF;
	
	-- Validate Date: ne može da bude vrednost datuma koja je u budućnosti.
	IF NEW.datum_registracije > CURDATE() THEN
		SIGNAL SQLSTATE '50005'
		SET MESSAGE_TEXT = 'Datum ne sme da bude u buducnosti';
	END IF;
	
	-- Validate Control Number: mora da bude vrednost koja je pozitivna, veća od 5 i mora da bude paran broj.
	IF NEW.kontrolni_broj_zapisa <= 5
	   OR NEW.kontrolni_broj_zapisa <= 0
      OR MOD(NEW.kontrolni_broj_zapisa, 2) <> 0 THEN
		SIGNAL SQLSTATE '50006'
		SET MESSAGE_TEXT = 'Broj kontrolnog zapisa nije u ispravnom formatu';
	END IF;
	
	-- Validate Model: RTO-12AE44
	IF NEW.broj_modela NOT RLIKE '^[A-Z]{3}\-[0-9]{2}[A-Z]{2}[0-9]{2}$' THEN
		SIGNAL SQLSTATE '50007'
		SET MESSAGE_TEXT = 'Broj modela nije u ispravnom formatu';
	END IF;
	
	-- Validate Bank Account: 265-1780310001126-61
	IF NEW.broj_tekuceg_racuna NOT RLIKE '^[0-9]{3}\-[0-9]{4,13}\-[0-9]{2}$' THEN
		SIGNAL SQLSTATE '50008'
		SET MESSAGE_TEXT = 'Broj racuna nije u ispravnom formatu';
	END IF;
	
	-- Validate kamata: mora da se kreće u opsegu od 0 do 50, uključujući te vrednosti.
	IF NEW.stopa_poreza < 0 AND NEW.stopa_poreza > 50 THEN
		SIGNAL SQLSTATE '50009'
		SET MESSAGE_TEXT = 'Porez nije u ispravnom formatu';
	END IF;
	
	-- Validate e-mail
	IF NEW.adresa_elektronske_poste NOT RLIKE '^[a-z0-9.-]+@[a-z0-9-]+(\.[a-z]{2,9})+$' THEN
		SIGNAL SQLSTATE '50010'
		SET MESSAGE_TEXT = 'Adresa e-poste nije u ispravnom stanju';
	END IF;
	
	-- Validate username: (sa liste: slova/cifre, opcioni . ili - između segmenata)
	IF NEW.korisnicko_ime NOT RLIKE '^[a-z]+[a-z0-9]*([.-][a-z0-9]+)*$' THEN
		SIGNAL SQLSTATE '50011'
		SET MESSAGE_TEXT = 'Korisnicko ime nije u ispravnom stanju';
	END IF;
	
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger baza_okidaci_vezba.trigger_tabelapodaci_bu
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trigger_tabelapodaci_bu` BEFORE UPDATE ON `tabelapodaci` FOR EACH ROW /* Before UPDATE */ 

BEGIN

	-- Validate Ime
	IF NEW.ime NOT RLIKE '^[A-Z][a-z]+( [A-Z][a-z]+)?$' THEN
		SIGNAL SQLSTATE '50001' 
		SET MESSAGE_TEXT = 'Ime nije u ispravnom formatu';
	END IF;
	
	-- Validate Prezime
	IF NEW.prezime NOT RLIKE '^[A-Z][a-z]+( [A-Z][a-z]+)?$' THEN
		SIGNAL SQLSTATE '50002' 
		SET MESSAGE_TEXT = 'Prezime nije u ispravnom formatu';
	END IF;
	
	-- Validate Phone Number
	IF NEW.broj_telefona NOT RLIKE '^0[0-9]{2}\/[0-9]{2}\-[0-9]{2}\-[0-9]{3}$' THEN
		SIGNAL SQLSTATE '50003'
		SET MESSAGE_TEXT = 'Telefon nije u ispravnom formatu';
	END IF;
	
	-- Validate License Plate
	IF NEW.registarska_oznaka NOT RLIKE '^[A-Z]{2} [0-9]{3,5}\-[A-Z]{2}$' THEN
		SIGNAL SQLSTATE '50004'
		SET MESSAGE_TEXT = 'Tablice nisu u ispravnom formatu';
	END IF;
	
	-- Validate Date: ne može da bude vrednost datuma koja je u budućnosti.
	IF NEW.datum_registracije > CURDATE() THEN
		SIGNAL SQLSTATE '50005'
		SET MESSAGE_TEXT = 'Datum ne sme da bude u buducnosti';
	END IF;
	
	-- Validate Control Number: mora da bude vrednost koja je pozitivna, veća od 5 i mora da bude paran broj.
	IF NEW.kontrolni_broj_zapisa <= 5
	   OR NEW.kontrolni_broj_zapisa <= 0
      OR MOD(NEW.kontrolni_broj_zapisa, 2) <> 0 THEN
		SIGNAL SQLSTATE '50006'
		SET MESSAGE_TEXT = 'Broj kontrolnog zapisa nije u ispravnom formatu';
	END IF;
	
	-- Validate Model: RTO-12AE44
	IF NEW.broj_modela NOT RLIKE '^[A-Z]{3}\-[0-9]{2}[A-Z]{2}[0-9]{2}$' THEN
		SIGNAL SQLSTATE '50007'
		SET MESSAGE_TEXT = 'Broj modela nije u ispravnom formatu';
	END IF;
	
	-- Validate Bank Account: 265-1780310001126-61
	IF NEW.broj_tekuceg_racuna NOT RLIKE '^[0-9]{3}\-[0-9]{4,13}\-[0-9]{2}$' THEN
		SIGNAL SQLSTATE '50008'
		SET MESSAGE_TEXT = 'Broj racuna nije u ispravnom formatu';
	END IF;
	
	-- Validate kamata: mora da se kreće u opsegu od 0 do 50, uključujući te vrednosti.
	IF NEW.stopa_poreza < 0 AND NEW.stopa_poreza > 50 THEN
		SIGNAL SQLSTATE '50009'
		SET MESSAGE_TEXT = 'Porez nije u ispravnom formatu';
	END IF;
	
	-- Validate e-mail
	IF NEW.adresa_elektronske_poste NOT RLIKE '^[a-z0-9.-]+@[a-z0-9-]+(\.[a-z]{2,9})+$' THEN
		SIGNAL SQLSTATE '50010'
		SET MESSAGE_TEXT = 'Adresa e-poste nije u ispravnom stanju';
	END IF;
	
	-- Validate username: (sa liste: slova/cifre, opcioni . ili - između segmenata)
	IF NEW.korisnicko_ime NOT RLIKE '^[a-z]+[a-z0-9]*([.-][a-z0-9]+)*$' THEN
		SIGNAL SQLSTATE '50011'
		SET MESSAGE_TEXT = 'Korisnicko ime nije u ispravnom stanju';
	END IF;
	
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;


-- Dumping database structure for baza_zivotinja
CREATE DATABASE IF NOT EXISTS `baza_zivotinja` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;
USE `baza_zivotinja`;

-- Dumping structure for table baza_zivotinja.rasa
CREATE TABLE IF NOT EXISTS `rasa` (
  `rasa_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `vrsta_id` int(10) unsigned NOT NULL,
  `naziv` varchar(100) NOT NULL,
  PRIMARY KEY (`rasa_id`),
  UNIQUE KEY `uq_rasa_vrsta_id_naziv` (`vrsta_id`,`naziv`),
  CONSTRAINT `fk_rasa_vrsta_id` FOREIGN KEY (`vrsta_id`) REFERENCES `vrsta` (`vrsta_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table baza_zivotinja.rasa: ~4 rows (approximately)
DELETE FROM `rasa`;
INSERT INTO `rasa` (`rasa_id`, `vrsta_id`, `naziv`) VALUES
	(1, 1, 'Haski'),
	(2, 1, 'Zlatni retriver'),
	(3, 1, 'Bigl'),
	(4, 2, 'Persijska');

-- Dumping structure for table baza_zivotinja.vakcina
CREATE TABLE IF NOT EXISTS `vakcina` (
  `vakcina_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `naziv` varchar(50) NOT NULL,
  PRIMARY KEY (`vakcina_id`),
  UNIQUE KEY `uq_vakcina_naziv` (`naziv`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table baza_zivotinja.vakcina: ~2 rows (approximately)
DELETE FROM `vakcina`;
INSERT INTO `vakcina` (`vakcina_id`, `naziv`) VALUES
	(1, 'vakcina1'),
	(2, 'vakcina2');

-- Dumping structure for table baza_zivotinja.vakcinacija
CREATE TABLE IF NOT EXISTS `vakcinacija` (
  `vakcinacija_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `zivotinja_id` int(10) unsigned NOT NULL,
  `vakcina_id` int(10) unsigned NOT NULL,
  `vakcinisan_at` date NOT NULL,
  PRIMARY KEY (`vakcinacija_id`),
  KEY `fk_vakcinacija_zivotinja_id` (`zivotinja_id`),
  KEY `fk_vakcinacija_vakcina_id` (`vakcina_id`),
  CONSTRAINT `fk_vakcinacija_vakcina_id` FOREIGN KEY (`vakcina_id`) REFERENCES `vakcina` (`vakcina_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_vakcinacija_zivotinja_id` FOREIGN KEY (`zivotinja_id`) REFERENCES `zivotinja` (`zivotinja_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table baza_zivotinja.vakcinacija: ~0 rows (approximately)
DELETE FROM `vakcinacija`;
INSERT INTO `vakcinacija` (`vakcinacija_id`, `zivotinja_id`, `vakcina_id`, `vakcinisan_at`) VALUES
	(2, 2, 2, '2025-07-02');

-- Dumping structure for table baza_zivotinja.vrsta
CREATE TABLE IF NOT EXISTS `vrsta` (
  `vrsta_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `naziv` varchar(100) NOT NULL,
  PRIMARY KEY (`vrsta_id`),
  UNIQUE KEY `uq_vrsta_naziv` (`naziv`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table baza_zivotinja.vrsta: ~2 rows (approximately)
DELETE FROM `vrsta`;
INSERT INTO `vrsta` (`vrsta_id`, `naziv`) VALUES
	(1, 'Canis Lupus Familiaris'),
	(2, 'Felis catus');

-- Dumping structure for table baza_zivotinja.zivotinja
CREATE TABLE IF NOT EXISTS `zivotinja` (
  `zivotinja_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `rasa_id` int(10) unsigned NOT NULL,
  `ime` varchar(32) NOT NULL,
  `masa` decimal(4,1) unsigned NOT NULL,
  `starost` int(10) unsigned NOT NULL,
  `pol` enum('m','z') NOT NULL,
  PRIMARY KEY (`zivotinja_id`),
  KEY `fk_zivotinja_rasa_id` (`rasa_id`),
  CONSTRAINT `fk_zivotinja_rasa_id` FOREIGN KEY (`rasa_id`) REFERENCES `rasa` (`rasa_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table baza_zivotinja.zivotinja: ~5 rows (approximately)
DELETE FROM `zivotinja`;
INSERT INTO `zivotinja` (`zivotinja_id`, `rasa_id`, `ime`, `masa`, `starost`, `pol`) VALUES
	(1, 1, 'Eko', 23.4, 96, 'm'),
	(2, 2, 'Maza', 30.5, 67, 'z'),
	(3, 3, 'Džimi', 25.0, 73, 'm'),
	(4, 4, 'Tom', 10.0, 14, 'm'),
	(6, 1, 'Pas1', 30.0, 15, 'm');


-- Dumping database structure for filmovi
CREATE DATABASE IF NOT EXISTS `filmovi` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;
USE `filmovi`;

-- Dumping structure for table filmovi.actor
CREATE TABLE IF NOT EXISTS `actor` (
  `actor_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `forename` varchar(64) NOT NULL,
  `surname` varchar(64) NOT NULL,
  PRIMARY KEY (`actor_id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table filmovi.actor: ~18 rows (approximately)
DELETE FROM `actor`;
INSERT INTO `actor` (`actor_id`, `forename`, `surname`) VALUES
	(1, 'Kate', 'Winslet'),
	(2, 'Leonardo', 'DiCaprio'),
	(3, 'Billy', 'Zane'),
	(4, 'Kathy', 'Bates'),
	(5, 'Bernard', 'Hill'),
	(6, 'Elijah', 'Wood'),
	(7, 'Cate', 'Blanchett'),
	(8, 'Ian', 'McKellen'),
	(9, 'Liv', 'Tyler'),
	(10, 'Orlando', 'Bloom'),
	(11, 'Sean', 'Astin'),
	(12, 'Nicole', 'Kidman'),
	(13, 'Daniel', 'Craig'),
	(14, 'Dakota', 'Blue Richards'),
	(15, 'Sam', 'Worthington'),
	(16, 'Zoe', 'Saldana'),
	(17, 'Sigourney', 'Weaver'),
	(18, 'Stephen', 'Lang');

-- Dumping structure for table filmovi.comment
CREATE TABLE IF NOT EXISTS `comment` (
  `comment_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `film_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `text` text NOT NULL,
  `is_approved` tinyint(1) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`comment_id`),
  KEY `fk_comment_film_id` (`film_id`),
  KEY `fk_comment_user_id` (`user_id`),
  CONSTRAINT `fk_comment_film_id` FOREIGN KEY (`film_id`) REFERENCES `film` (`film_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_comment_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table filmovi.comment: ~7 rows (approximately)
DELETE FROM `comment`;
INSERT INTO `comment` (`comment_id`, `film_id`, `user_id`, `text`, `is_approved`) VALUES
	(1, 4, 1, 'Neki komentar', 1),
	(2, 4, 2, 'Neki drugi komentar...', 0),
	(3, 4, 1, 'Komentar...', 1),
	(4, 3, 2, 'Komentar...', 1),
	(5, 3, 3, 'Komentar...', 1),
	(6, 2, 3, 'Komentar...', 1),
	(7, 1, 1, 'Komentar 123...', 1);

-- Dumping structure for table filmovi.director
CREATE TABLE IF NOT EXISTS `director` (
  `director_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `forename` varchar(32) NOT NULL,
  `surname` varchar(32) NOT NULL,
  PRIMARY KEY (`director_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table filmovi.director: ~3 rows (approximately)
DELETE FROM `director`;
INSERT INTO `director` (`director_id`, `forename`, `surname`) VALUES
	(1, 'James', 'Cameron'),
	(2, 'Peter', 'Jackson'),
	(3, 'Chris', 'Weitz');

-- Dumping structure for table filmovi.film
CREATE TABLE IF NOT EXISTS `film` (
  `film_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `director_id` int(10) unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `year` smallint(4) unsigned NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY (`film_id`),
  KEY `fk_film_director_id` (`director_id`),
  CONSTRAINT `fk_film_director_id` FOREIGN KEY (`director_id`) REFERENCES `director` (`director_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table filmovi.film: ~4 rows (approximately)
DELETE FROM `film`;
INSERT INTO `film` (`film_id`, `director_id`, `title`, `year`, `description`) VALUES
	(1, 1, 'Titanic', 1997, 'A seventeen-year-old aristocrat falls in love with a kind but poor artist aboard the luxurious, ill-fated R.M.S. Titanic.'),
	(2, 2, 'The lord of the rings: The fellowship of the ring', 2001, 'A meek Hobbit from the Shire and eight companions set out on a journey to destroy the powerful One Ring and save Middle-earth from the Dark Lord Sauron.'),
	(3, 3, 'The Golden Compass', 2007, 'In a parallel universe, young Lyra Belacqua journeys to the far North to save her best friend and other kidnapped children from terrible experiments by a mysterious organization.'),
	(4, 1, 'Avatar', 2009, 'A paraplegic Marine dispatched to the moon Pandora on a unique mission becomes torn between following his orders and protecting the world he feels is his home.');

-- Dumping structure for table filmovi.role
CREATE TABLE IF NOT EXISTS `role` (
  `role_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `film_id` int(10) unsigned NOT NULL,
  `actor_id` int(10) unsigned NOT NULL,
  `name` varchar(64) NOT NULL,
  `type` enum('P','V') NOT NULL DEFAULT 'P',
  PRIMARY KEY (`role_id`),
  KEY `fk_role_film_id` (`film_id`),
  KEY `fk_role_actor_id` (`actor_id`),
  CONSTRAINT `fk_role_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `actor` (`actor_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_role_film_id` FOREIGN KEY (`film_id`) REFERENCES `film` (`film_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table filmovi.role: ~20 rows (approximately)
DELETE FROM `role`;
INSERT INTO `role` (`role_id`, `film_id`, `actor_id`, `name`, `type`) VALUES
	(1, 1, 1, 'Rose Dewitt Bukater', 'P'),
	(2, 1, 2, 'Jack Dawson', 'P'),
	(3, 1, 3, 'Cal Hockley', 'P'),
	(4, 1, 4, 'Molly Brown', 'P'),
	(5, 1, 5, 'Captain Smith', 'P'),
	(6, 2, 6, 'Frodo', 'P'),
	(7, 2, 7, 'Galadriel', 'P'),
	(8, 2, 8, 'Gandalf', 'P'),
	(9, 2, 9, 'Arwen', 'P'),
	(10, 2, 10, 'Legolas', 'P'),
	(11, 2, 11, 'Sam', 'P'),
	(12, 3, 12, 'Mrs. Coulter', 'P'),
	(13, 3, 13, 'Lord Asriel', 'P'),
	(14, 3, 14, 'Lyra', 'P'),
	(15, 3, 8, 'Iorek Byrnison', 'V'),
	(16, 3, 4, 'Hester', 'V'),
	(17, 4, 15, 'Jake Sully', 'P'),
	(18, 4, 16, 'Neytiri (as Zoë Saldana)', 'P'),
	(19, 4, 17, 'Dr. Grace Augustine', 'P'),
	(20, 4, 18, 'Colonel Miles Quaritch', 'P');

-- Dumping structure for table filmovi.user
CREATE TABLE IF NOT EXISTS `user` (
  `user_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(32) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uq_user_username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table filmovi.user: ~3 rows (approximately)
DELETE FROM `user`;
INSERT INTO `user` (`user_id`, `username`, `password_hash`) VALUES
	(1, 'avidakovic', '#####'),
	(2, 'pperic', '#####'),
	(3, 'mmarkovic', '#####');

-- Dumping structure for table filmovi.user_login
CREATE TABLE IF NOT EXISTS `user_login` (
  `user_login_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `ip_address` varchar(15) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`user_login_id`),
  KEY `fk_user_login_user_id` (`user_id`),
  CONSTRAINT `fk_user_login_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table filmovi.user_login: ~5 rows (approximately)
DELETE FROM `user_login`;
INSERT INTO `user_login` (`user_login_id`, `user_id`, `ip_address`, `created_at`) VALUES
	(1, 1, '1.2.4.5', '2024-10-24 10:12:00'),
	(2, 1, '3.1.1.3', '2024-10-24 10:13:54'),
	(3, 2, '1.1.1.1', '2024-10-21 10:14:09'),
	(4, 3, '2.2.2.2', '2024-10-23 10:14:22'),
	(5, 3, '2.2.2.2', '2024-10-24 08:14:30');

-- Dumping structure for view filmovi.view__dopunjene_informacije_o_filmovima
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `view__dopunjene_informacije_o_filmovima` (
	`film_id` INT(10) UNSIGNED NOT NULL,
	`director_id` INT(10) UNSIGNED NOT NULL,
	`title` VARCHAR(1) NOT NULL COLLATE 'utf8_unicode_ci',
	`year` SMALLINT(4) UNSIGNED NOT NULL,
	`description` TEXT NOT NULL COLLATE 'utf8_unicode_ci',
	`director_full_name` VARCHAR(1) NOT NULL COLLATE 'utf8_unicode_ci',
	`comment_count` BIGINT(21) NOT NULL
);

-- Dumping structure for view filmovi.view__prosiren_info_o_komentarima
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `view__prosiren_info_o_komentarima` (
	`comment_id` INT(10) UNSIGNED NOT NULL,
	`film_id` INT(10) UNSIGNED NOT NULL,
	`user_id` INT(10) UNSIGNED NOT NULL,
	`text` TEXT NOT NULL COLLATE 'utf8_unicode_ci',
	`is_approved` TINYINT(1) UNSIGNED NOT NULL,
	`username` VARCHAR(1) NOT NULL COLLATE 'utf8_unicode_ci',
	`last_logged_in_at` DATETIME NULL,
	`title` VARCHAR(1) NOT NULL COLLATE 'utf8_unicode_ci'
);

-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `view__dopunjene_informacije_o_filmovima`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `view__dopunjene_informacije_o_filmovima` AS SELECT
	film.*,
	CONCAT(director.forename, ' ', director.surname) AS director_full_name,
	COUNT(`comment`.comment_id) AS comment_count
FROM film
INNER JOIN director ON film.director_id = director.director_id
LEFT JOIN `comment` ON film.film_id = `comment`.film_id
GROUP BY film.film_id 
;

-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `view__prosiren_info_o_komentarima`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `view__prosiren_info_o_komentarima` AS SELECT
	`comment`.*,
	`user`.username,
	MAX(user_login.created_at) AS last_logged_in_at,
	film.title
FROM `comment`
INNER JOIN `user` ON `comment`.user_id = `user`.user_id
INNER JOIN user_login ON `user`.user_id = user_login.user_id
INNER JOIN film ON `comment`.film_id = film.film_id
GROUP BY `comment`.comment_id 
;


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

-- Dumping data for table imdtb_2025202590.angazovanje: ~0 rows (approximately)
DELETE FROM `angazovanje`;

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

-- Dumping data for table imdtb_2025202590.posao: ~0 rows (approximately)
DELETE FROM `posao`;

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

-- Dumping data for table imdtb_2025202590.projekat: ~0 rows (approximately)
DELETE FROM `projekat`;

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

-- Dumping data for table imdtb_2025202590.zaposleni: ~0 rows (approximately)
DELETE FROM `zaposleni`;

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
