-- phpMyAdmin SQL Dump
-- version 5.1.2
-- https://www.phpmyadmin.net/
--
-- Anamakine: localhost:3306
-- Üretim Zamanı: 27 May 2023, 20:00:07
-- Sunucu sürümü: 5.7.24
-- PHP Sürümü: 8.0.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Veritabanı: `employee_tracking_system`
--

DELIMITER $$
--
-- Yordamlar
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteEmployee` (IN `empTCKN` VARCHAR(11))   BEGIN
    DELETE FROM EmpDept WHERE TCKN = empTCKN;
    DELETE FROM Payment WHERE TCKN = empTCKN;
    DELETE FROM Permission WHERE TCKN = empTCKN;
    DELETE FROM TimeLog WHERE TCKN = empTCKN;
    DELETE FROM EmpEmail WHERE TCKN = empTCKN;
    DELETE FROM Employee WHERE TCKN = empTCKN;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SalaryRaiseEmp` (IN `salaryRaise` DECIMAL(5,2))   BEGIN
    UPDATE Employee
    SET Salary = Salary + (Salary * salaryRaise / 100.0);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `department`
--

CREATE TABLE `department` (
  `DeptID` char(7) NOT NULL,
  `DeptName` varchar(70) NOT NULL,
  `DeptInfo` varchar(255) NOT NULL,
  `DeptManager` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Tablo döküm verisi `department`
--

INSERT INTO `department` (`DeptID`, `DeptName`, `DeptInfo`, `DeptManager`) VALUES
('1', 'Halkla İlişkiler', 'Yönetim', 'Sevdenur Deniz'),
('2', 'Pazarlama ', 'Pazarlama departmanı reklam, promosyon, halkla ilişkiler, pazar araştırması ve müşteri ilişkileri gibi alanlarda faaliyet gösterir.', 'Mehmet Yıldız');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `empdept`
--

CREATE TABLE `empdept` (
  `TCKN` char(11) NOT NULL,
  `DeptID` char(7) NOT NULL,
  `DeptStartDate` date NOT NULL,
  `DeptDepartureDate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `empemail`
--

CREATE TABLE `empemail` (
  `TCKN` char(11) NOT NULL,
  `Email` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Tablo döküm verisi `empemail`
--

INSERT INTO `empemail` (`TCKN`, `Email`) VALUES
('12912912912', 'deneme@gmail.com');

-- --------------------------------------------------------

--
-- Görünüm yapısı durumu `empinfo2`
-- (Asıl görünüm için aşağıya bakın)
--
CREATE TABLE `empinfo2` (
`TCKN` char(11)
,`Name` varchar(92)
,`PhoneNumber` varchar(11)
,`Email` varchar(100)
,`BirthDate` date
,`DeptName` varchar(70)
,`RoleName` varchar(30)
,`Salary` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `employee`
--

CREATE TABLE `employee` (
  `TCKN` char(11) NOT NULL,
  `FirstName` varchar(30) NOT NULL,
  `Minit` varchar(30) DEFAULT NULL,
  `LastName` varchar(30) NOT NULL,
  `Address` varchar(255) NOT NULL,
  `BirthDate` date NOT NULL,
  `NumberOfPermits` tinyint(4) NOT NULL,
  `PhoneNumber` varchar(11) NOT NULL,
  `Salary` decimal(10,2) NOT NULL,
  `Gender` char(30) NOT NULL,
  `StartDate` date NOT NULL,
  `DepartureDate` date DEFAULT NULL,
  `DeptID` char(7) NOT NULL,
  `RouteID` int(11) NOT NULL,
  `RoleID` char(7) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Tablo döküm verisi `employee`
--

INSERT INTO `employee` (`TCKN`, `FirstName`, `Minit`, `LastName`, `Address`, `BirthDate`, `NumberOfPermits`, `PhoneNumber`, `Salary`, `Gender`, `StartDate`, `DepartureDate`, `DeptID`, `RouteID`, `RoleID`) VALUES
('12312312312', 'Ali', '', 'Tekin', 'Akdeğirmen mah. ', '1998-10-31', 65, '05555555544', '9500.00', 'Erkek', '2020-06-17', '2021-10-17', '1', 7, '2'),
('12912312312', 'Mehmet', '', 'Altın', 'Sivas', '1995-07-31', 8, '05555544555', '15000.00', 'Kadın', '2019-02-18', '2023-05-10', '1', 8, '2'),
('12912912912', 'Nurgül', '', 'Deniz', 'Fatih mah', '1987-10-12', 37, '05555544555', '4500.00', 'Kadın', '2019-11-17', '2023-05-10', '1', 8, '2'),
('33333333333', 'Sevdenur Deniz', 'Sevdenur', 'Deniz', 'fatih mah. 93.sok no:6 sivas/merkez', '2000-05-18', 0, '05555544555', '1500.00', 'Kadın', '2000-05-18', NULL, '1', 1, '2'),
('45454545454', 'Ayşenur', '', 'Nur', 'Denedim', '2002-06-30', 12, '05555544555', '15000.00', 'Kadın', '2023-05-19', '2023-05-27', '1', 4, '2'),
('77777777777', 'Aslı', 'Gül', 'Çimen', 'Mevlana', '1992-06-30', 14, '05555555544', '5600.00', 'Kadın', '2020-06-18', '2023-05-25', '1', 8, '2');

--
-- Tetikleyiciler `employee`
--
DELIMITER $$
CREATE TRIGGER `tg_CheckSeats` AFTER INSERT ON `employee` FOR EACH ROW BEGIN
    -- inserted table routeid numarasini tuttuk
    SET @insertedRouteID = NEW.RouteID;

    -- servisdeki routeid esitlemesi yapip hangi servisin koltuk sayisi kac onu buldum
    SELECT s.NumberOfSeats INTO @NumberofSeats
    FROM Service AS s
    WHERE s.RouteID = @insertedRouteID;

    -- emp tablosunda routeid ayni olan tuple sayisina bakti
    SET @numberofEmp = (
        SELECT COUNT(*)
        FROM Employee e
        WHERE e.RouteID = @insertedRouteID
    );

    IF @numberofEmp > @NumberofSeats THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Serviste Boş Koltuk Kalmamıştır';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Görünüm yapısı durumu `empservice`
-- (Asıl görünüm için aşağıya bakın)
--
CREATE TABLE `empservice` (
`TCKN` char(11)
,`AdSoyad` varchar(92)
,`NumberPlate` varchar(11)
,`DriverName` varchar(30)
);

-- --------------------------------------------------------

--
-- Görünüm yapısı durumu `emptimelog`
-- (Asıl görünüm için aşağıya bakın)
--
CREATE TABLE `emptimelog` (
`TCKN` char(11)
,`AdSoyad` varchar(92)
,`LoginDateTime` datetime
,`DepartureDateTime` datetime
);

-- --------------------------------------------------------

--
-- Görünüm yapısı durumu `leavedaysemployee`
-- (Asıl görünüm için aşağıya bakın)
--
CREATE TABLE `leavedaysemployee` (
`FirstName` varchar(30)
,`LastName` varchar(30)
,`NumLeaveDays` decimal(29,0)
,`Month` int(2)
,`Year` int(4)
);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `payment`
--

CREATE TABLE `payment` (
  `PaymentID` int(11) NOT NULL,
  `TCKN` char(11) NOT NULL,
  `AmountOfPayment` decimal(10,2) NOT NULL,
  `PaymentDate` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Tablo döküm verisi `payment`
--

INSERT INTO `payment` (`PaymentID`, `TCKN`, `AmountOfPayment`, `PaymentDate`) VALUES
(1, '12912912912', '150.00', '2023-05-24');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `permission`
--

CREATE TABLE `permission` (
  `PermID` int(11) NOT NULL,
  `PermType` varchar(30) DEFAULT NULL,
  `PermStartDate` date DEFAULT NULL,
  `PermEndDate` date DEFAULT NULL,
  `TCKN` char(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Tablo döküm verisi `permission`
--

INSERT INTO `permission` (`PermID`, `PermType`, `PermStartDate`, `PermEndDate`, `TCKN`) VALUES
(1, 'raporlu', '2023-05-19', '2023-05-20', '12312312312'),
(2, 'raporlu', '2023-05-19', '2023-05-03', '12912312312'),
(3, 'raporlu', '2023-05-19', '2023-05-03', '12312312312'),
(5, 'raporlu', '2023-05-19', '2023-05-04', '77777777777'),
(6, 'raporlu', '2023-05-19', '2023-05-04', '12912912912'),
(7, 'raporlu', '2023-05-19', '2023-05-20', '12912912912'),
(11, 'raporlu', '2023-05-26', '2023-05-30', '77777777777'),
(12, 'raporlu', '2023-05-19', '2023-05-20', '12912912912'),
(13, 'raporlu', '2023-05-19', '2023-05-27', '12912312312');

--
-- Tetikleyiciler `permission`
--
DELIMITER $$
CREATE TRIGGER `trg_permission_insert` AFTER INSERT ON `permission` FOR EACH ROW BEGIN
    DECLARE EmployeePermits INT;

    SELECT NumberOfPermits INTO EmployeePermits
    FROM Employee
    WHERE TCKN = NEW.TCKN;

    IF DATEDIFF(NEW.PermEndDate, NEW.PermStartDate) + 1 <= EmployeePermits THEN
        UPDATE Employee
        SET NumberOfPermits = NumberOfPermits - (DATEDIFF(NEW.PermEndDate, NEW.PermStartDate) + 1)
        WHERE TCKN = NEW.TCKN;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'İzin hakkınız kalmamıştır.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `role`
--

CREATE TABLE `role` (
  `RoleID` char(7) NOT NULL,
  `RoleName` varchar(30) NOT NULL,
  `RoleDesc` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Tablo döküm verisi `role`
--

INSERT INTO `role` (`RoleID`, `RoleName`, `RoleDesc`) VALUES
('2', 'Medya İlişkileri Uzmanı', 'Kurumun medya iletişimi ve basın ilişkilerini yöneten kişidir.'),
('3', 'Finans Müdürü', 'Finans departmanı, şirketin mali işlerinden sorumludur.'),
('4', 'Pazarlama Müdürü', ' Pazarlama departmanı, ürün ve hizmetlerin pazarlanması, reklam');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `service`
--

CREATE TABLE `service` (
  `RouteID` int(11) NOT NULL,
  `NumberPlate` varchar(11) NOT NULL,
  `DepartureTime` datetime NOT NULL,
  `DriverName` varchar(30) NOT NULL,
  `NumberOfSeats` tinyint(4) NOT NULL,
  `Route` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Tablo döküm verisi `service`
--

INSERT INTO `service` (`RouteID`, `NumberPlate`, `DepartureTime`, `DriverName`, `NumberOfSeats`, `Route`) VALUES
(1, '1', '2023-05-16 15:16:39', 'Mehmet Bey', 15, 'Fatih Mah.'),
(2, '58SD58', '2023-05-16 20:44:30', 'Samet', 1, 'Akdeğirmen'),
(3, '58ADK587', '2023-05-25 00:00:00', 'Ahmet', 15, 'Fatih Mah.'),
(4, '34TR548', '2023-05-25 00:00:00', 'Ahmet', 15, 'Mevlana'),
(5, '34TR548', '2023-05-26 00:00:00', 'denemeServis', 15, 'Kümbet'),
(7, '58AB456', '2023-05-19 00:00:00', 'Ali Tekin', 45, 'Yiğitler'),
(8, '44TR549', '2023-05-18 00:00:00', 'serviscii', 15, 'Mevlana'),
(9, '58NP667', '2023-05-19 00:00:00', 'serviscii', 20, 'Fatih Mah.'),
(10, '34TR548', '2023-05-27 00:00:00', 'Ahmet', 20, 'Mevlana');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `timelog`
--

CREATE TABLE `timelog` (
  `LoginID` int(11) NOT NULL,
  `TCKN` char(11) NOT NULL,
  `LoginDateTime` datetime NOT NULL,
  `DepartureDateTime` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Tablo döküm verisi `timelog`
--

INSERT INTO `timelog` (`LoginID`, `TCKN`, `LoginDateTime`, `DepartureDateTime`) VALUES
(1, '12912912912', '2023-05-18 22:18:42', '2023-05-03 20:10:42');

-- --------------------------------------------------------

--
-- Görünüm yapısı `empinfo2`
--
DROP TABLE IF EXISTS `empinfo2`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `empinfo2`  AS SELECT `e`.`TCKN` AS `TCKN`, concat(`e`.`FirstName`,' ',`e`.`Minit`,' ',`e`.`LastName`) AS `Name`, `e`.`PhoneNumber` AS `PhoneNumber`, `ee`.`Email` AS `Email`, `e`.`BirthDate` AS `BirthDate`, `d`.`DeptName` AS `DeptName`, `r`.`RoleName` AS `RoleName`, `e`.`Salary` AS `Salary` FROM (((`employee` `e` join `department` `d` on((`e`.`DeptID` = `d`.`DeptID`))) join `role` `r` on((`e`.`RoleID` = `r`.`RoleID`))) join `empemail` `ee` on((`ee`.`TCKN` = `e`.`TCKN`)))  ;

-- --------------------------------------------------------

--
-- Görünüm yapısı `empservice`
--
DROP TABLE IF EXISTS `empservice`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `empservice`  AS SELECT `e`.`TCKN` AS `TCKN`, concat(`e`.`FirstName`,' ',`e`.`Minit`,' ',`e`.`LastName`) AS `AdSoyad`, `s`.`NumberPlate` AS `NumberPlate`, `s`.`DriverName` AS `DriverName` FROM (`employee` `e` join `service` `s`) WHERE (`e`.`RouteID` = `s`.`RouteID`)  ;

-- --------------------------------------------------------

--
-- Görünüm yapısı `emptimelog`
--
DROP TABLE IF EXISTS `emptimelog`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `emptimelog`  AS SELECT `t`.`TCKN` AS `TCKN`, concat(`e`.`FirstName`,' ',`e`.`Minit`,' ',`e`.`LastName`) AS `AdSoyad`, `t`.`LoginDateTime` AS `LoginDateTime`, `t`.`DepartureDateTime` AS `DepartureDateTime` FROM (`employee` `e` join `timelog` `t`) WHERE (`e`.`TCKN` = `t`.`TCKN`)  ;

-- --------------------------------------------------------

--
-- Görünüm yapısı `leavedaysemployee`
--
DROP TABLE IF EXISTS `leavedaysemployee`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `leavedaysemployee`  AS SELECT `e`.`FirstName` AS `FirstName`, `e`.`LastName` AS `LastName`, sum(((to_days(`p`.`PermEndDate`) - to_days(`p`.`PermStartDate`)) + 1)) AS `NumLeaveDays`, month(`p`.`PermStartDate`) AS `Month`, year(`p`.`PermStartDate`) AS `Year` FROM (`employee` `e` join `permission` `p` on((`e`.`TCKN` = `p`.`TCKN`))) GROUP BY `e`.`FirstName`, `e`.`LastName`, month(`p`.`PermStartDate`), year(`p`.`PermStartDate`)  ;

--
-- Dökümü yapılmış tablolar için indeksler
--

--
-- Tablo için indeksler `department`
--
ALTER TABLE `department`
  ADD PRIMARY KEY (`DeptID`);

--
-- Tablo için indeksler `empdept`
--
ALTER TABLE `empdept`
  ADD PRIMARY KEY (`TCKN`,`DeptID`),
  ADD KEY `FK_edDeptID` (`DeptID`);

--
-- Tablo için indeksler `empemail`
--
ALTER TABLE `empemail`
  ADD PRIMARY KEY (`TCKN`,`Email`);

--
-- Tablo için indeksler `employee`
--
ALTER TABLE `employee`
  ADD PRIMARY KEY (`TCKN`),
  ADD KEY `FK_DeptID` (`DeptID`),
  ADD KEY `FK_RouteID` (`RouteID`),
  ADD KEY `FK_RoleID` (`RoleID`);

--
-- Tablo için indeksler `payment`
--
ALTER TABLE `payment`
  ADD PRIMARY KEY (`PaymentID`),
  ADD KEY `FK_PaymentTCKN` (`TCKN`);

--
-- Tablo için indeksler `permission`
--
ALTER TABLE `permission`
  ADD PRIMARY KEY (`PermID`),
  ADD KEY `FK_PermTCKN` (`TCKN`);

--
-- Tablo için indeksler `role`
--
ALTER TABLE `role`
  ADD PRIMARY KEY (`RoleID`);

--
-- Tablo için indeksler `service`
--
ALTER TABLE `service`
  ADD PRIMARY KEY (`RouteID`);

--
-- Tablo için indeksler `timelog`
--
ALTER TABLE `timelog`
  ADD PRIMARY KEY (`LoginID`),
  ADD KEY `FK_TimeLogTCKN` (`TCKN`);

--
-- Dökümü yapılmış tablolar için AUTO_INCREMENT değeri
--

--
-- Tablo için AUTO_INCREMENT değeri `payment`
--
ALTER TABLE `payment`
  MODIFY `PaymentID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Tablo için AUTO_INCREMENT değeri `permission`
--
ALTER TABLE `permission`
  MODIFY `PermID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- Tablo için AUTO_INCREMENT değeri `service`
--
ALTER TABLE `service`
  MODIFY `RouteID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Tablo için AUTO_INCREMENT değeri `timelog`
--
ALTER TABLE `timelog`
  MODIFY `LoginID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Dökümü yapılmış tablolar için kısıtlamalar
--

--
-- Tablo kısıtlamaları `empdept`
--
ALTER TABLE `empdept`
  ADD CONSTRAINT `FK_edDeptID` FOREIGN KEY (`DeptID`) REFERENCES `department` (`DeptID`),
  ADD CONSTRAINT `FK_edTCKN` FOREIGN KEY (`TCKN`) REFERENCES `employee` (`TCKN`);

--
-- Tablo kısıtlamaları `empemail`
--
ALTER TABLE `empemail`
  ADD CONSTRAINT `FK_EEmailTCKN` FOREIGN KEY (`TCKN`) REFERENCES `employee` (`TCKN`);

--
-- Tablo kısıtlamaları `employee`
--
ALTER TABLE `employee`
  ADD CONSTRAINT `FK_DeptID` FOREIGN KEY (`DeptID`) REFERENCES `department` (`DeptID`),
  ADD CONSTRAINT `FK_RoleID` FOREIGN KEY (`RoleID`) REFERENCES `role` (`RoleID`),
  ADD CONSTRAINT `FK_RouteID` FOREIGN KEY (`RouteID`) REFERENCES `service` (`RouteID`);

--
-- Tablo kısıtlamaları `payment`
--
ALTER TABLE `payment`
  ADD CONSTRAINT `FK_PaymentTCKN` FOREIGN KEY (`TCKN`) REFERENCES `employee` (`TCKN`);

--
-- Tablo kısıtlamaları `permission`
--
ALTER TABLE `permission`
  ADD CONSTRAINT `FK_PermTCKN` FOREIGN KEY (`TCKN`) REFERENCES `employee` (`TCKN`);

--
-- Tablo kısıtlamaları `timelog`
--
ALTER TABLE `timelog`
  ADD CONSTRAINT `FK_TimeLogTCKN` FOREIGN KEY (`TCKN`) REFERENCES `employee` (`TCKN`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
