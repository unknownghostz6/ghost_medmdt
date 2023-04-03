CREATE TABLE `user_med_mdt` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`char_id` int(11) DEFAULT NULL,
	`notes` varchar(255) DEFAULT NULL,
	`mugshot_url` varchar(255) DEFAULT NULL,
	`bail` bit DEFAULT NULL,

	PRIMARY KEY (`id`)
);

CREATE TABLE `user_med_convictions` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`char_id` int(11) DEFAULT NULL,
	`offense` varchar(255) DEFAULT NULL,
	`count` int(11) DEFAULT NULL,
	
	PRIMARY KEY (`id`)
);

CREATE TABLE `mdt_med_reports` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`char_id` int(11) DEFAULT NULL,
	`title` varchar(255) DEFAULT NULL,
	`incident` longtext DEFAULT NULL,
    `charges` longtext DEFAULT NULL,
    `author` varchar(255) DEFAULT NULL,
	`name` varchar(255) DEFAULT NULL,
    `date` varchar(255) DEFAULT NULL,

	PRIMARY KEY (`id`)
);

CREATE TABLE `mdt_med_warrants` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`name` varchar(255) DEFAULT NULL,
	`char_id` int(11) DEFAULT NULL,
	`report_id` int(11) DEFAULT NULL,
	`report_title` varchar(255) DEFAULT NULL,
	`charges` longtext DEFAULT NULL,
	`date` varchar(255) DEFAULT NULL,
	`expire` varchar(255) DEFAULT NULL,
	`notes` varchar(255) DEFAULT NULL,
	`author` varchar(255) DEFAULT NULL,

	PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `med_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `category` int(11) DEFAULT NULL,
  `jailtime` int(11) DEFAULT NULL,
	
       PRIMARY KEY (`id`)
);

CREATE TABLE `mdt_med_telegrams` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`title` varchar(255) DEFAULT NULL,
	`incident` longtext DEFAULT NULL,
    `author` varchar(255) DEFAULT NULL,
    `date` varchar(255) DEFAULT NULL,

	PRIMARY KEY (`id`)
);

INSERT INTO `med_types` (`id`, `label`, `amount`, `category`, `jailtime`) VALUES
(1, 'Bruise', 0, 0, 0),
(2, 'Cold', 0, 0, 0),
(3, 'Cholera', 0, 0, 0),
(4, 'Cut', 0, 0, 0),
(5, 'Fractured Left Arm', 0, 0, 0),
(6, 'Fractured Right Arm', 0, 0, 0),
(7, 'Fractured Left Leg', 0, 0, 0),
(8, 'Fractured Right Leg', 0, 0, 0),
(9, 'Gunshot Wound Arm', 0, 0, 0),
(10, 'Gunshot Wound Leg', 0, 0, 0),
(11, 'General Pain Symptoms', 0, 0, 0),
(12, 'Head Injury', 0, 0, 0),
(13, 'Lower Body Gunshot Wound', 0, 0, 0),
(14, 'Malaria', 0, 0, 0),
(15, 'Nasal fracture', 0, 0, 0),
(16, 'Other Complaints', 0, 0, 0);
(17, 'Skin Disease', 0, 0, 0),
(18, 'Upper Body Gunshot Wound', 0, 0, 0),
