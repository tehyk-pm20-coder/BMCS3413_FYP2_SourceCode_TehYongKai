-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 30, 2025 at 10:40 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `fyp`
--

-- --------------------------------------------------------

--
-- Table structure for table `blockchain`
--

CREATE TABLE `blockchain` (
  `block_id` int(11) NOT NULL,
  `ticket_id` int(11) NOT NULL,
  `previous_hash` varchar(255) DEFAULT NULL,
  `block_hash` varchar(255) DEFAULT NULL,
  `ticket_state_hash` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `blockchain`
--

INSERT INTO `blockchain` (`block_id`, `ticket_id`, `previous_hash`, `block_hash`, `ticket_state_hash`, `created_at`) VALUES
(54, 55, 'GENESIS', '2b4c091b400a19f332d74cfeb28051bfd8f5f4d303aff633a47e48a1568d8085', 'a0e51b0a2a1a537bf03e2acc131efc4dc63311652ec37e280a9ccde6af7eade2', '2025-11-23 14:48:22'),
(55, 56, '2b4c091b400a19f332d74cfeb28051bfd8f5f4d303aff633a47e48a1568d8085', '6ef973feb7da743f1346a0e5277e084cecf977f72da0d7007dfec658349aa2e3', 'ed983a52a4fd394521b3765a28aefb076476a709c04b11242ac97e5853d83668', '2025-11-23 14:48:41'),
(56, 57, '6ef973feb7da743f1346a0e5277e084cecf977f72da0d7007dfec658349aa2e3', '542621363e93c568d16a2a420b0f2f458e1fa8bbc9b211963aad509ea6cecdd1', '30244b7753ae93fe2710d8292476b2db61e8d22c1ecd1dc7c3aeadb15fcad42f', '2025-11-23 14:48:45'),
(57, 58, '542621363e93c568d16a2a420b0f2f458e1fa8bbc9b211963aad509ea6cecdd1', '86df38bea598f7f861e288d9bb9d05d2663eb46252e07b34de75b93202b0fdec', 'e6c27aba878c5364e3e4cb4fdad84cb939f107154756844ef2feec77cb135823', '2025-11-23 14:48:48'),
(58, 59, '86df38bea598f7f861e288d9bb9d05d2663eb46252e07b34de75b93202b0fdec', 'eff3fe330cbfb198bde260b63d8a2b26c2f9c8aeefdfc49c86457e5e7085d460', '95175fe8c8ce2cb44f018684b0d2207e208bda983232654ebe3d2841e20fec69', '2025-11-23 14:49:31'),
(59, 60, 'eff3fe330cbfb198bde260b63d8a2b26c2f9c8aeefdfc49c86457e5e7085d460', '32aa45014e469ee12c7c0b51e17420ea1dbf00bf86b6838652fba5b7ba4fd7ad', '3c9830b408ff533f3742616b4da5b7e7683c6a287a5c797f7060f1b0b09e9c5e', '2025-11-23 14:49:35'),
(60, 61, '32aa45014e469ee12c7c0b51e17420ea1dbf00bf86b6838652fba5b7ba4fd7ad', '36cc9b904a4b377363378841bff048a4b85f5468a6012e183f126f8480cfbe31', '2ecc51320be4670c887649897c52918b52befb511ca71780799282eadb7ff657', '2025-11-23 14:49:38'),
(61, 62, '36cc9b904a4b377363378841bff048a4b85f5468a6012e183f126f8480cfbe31', '7bcff1abfe32c6a3afb57a8ad86a2802a9c576277a3ce5e53498c69a216aa4cc', '077de8ea547f4a61289b360209753f81eb3d2bae0efea26a90d8132633123e6b', '2025-11-23 14:50:02'),
(62, 63, '7bcff1abfe32c6a3afb57a8ad86a2802a9c576277a3ce5e53498c69a216aa4cc', 'a69125c3ae7cfd03dbbf795b88bd55a333f4cc73c174d7a6679182552ee5e7de', '484fa113036baa63f3c053b5e6239f80af026ce04f07a773c394b3cbd68d60b8', '2025-11-23 14:50:06'),
(63, 64, 'a69125c3ae7cfd03dbbf795b88bd55a333f4cc73c174d7a6679182552ee5e7de', 'f89158d0349f47f518495073e3ba2213fa6979e468f30f96a554f8e3cd7ae6b1', '4395d735e95cf05a6f760b70a7b0b9589b0f9576d625e969947bc3de440515ea', '2025-11-23 14:50:10'),
(64, 65, 'f89158d0349f47f518495073e3ba2213fa6979e468f30f96a554f8e3cd7ae6b1', '42150947cdcb5fdbff3d2d14b62d137d2616150a75699e05d7b5759a2797c8f5', 'f8b02c98238ceeb748845c2e04b71552d0016dd2571abaa618f090970a629437', '2025-11-23 14:50:13'),
(65, 66, '42150947cdcb5fdbff3d2d14b62d137d2616150a75699e05d7b5759a2797c8f5', '441f645d571cf8d5013341b1cc7a533d4c2d75ee4de7f90a79331614baec59f1', 'eb0c069e9237c35b0ca520f356b7773261db1eee2c3158bc52f97cad45edc645', '2025-11-23 14:51:06'),
(66, 64, '441f645d571cf8d5013341b1cc7a533d4c2d75ee4de7f90a79331614baec59f1', '3a026b4ff322df29230cbdf3dc0f58f2632b2e66dd26c34c2ae6c82f3eee3f43', 'd5e883271cff9166381989b1883ae838a4e30b242aaed43693252cc408fe51cf', '2025-11-23 14:52:32'),
(67, 58, '3a026b4ff322df29230cbdf3dc0f58f2632b2e66dd26c34c2ae6c82f3eee3f43', '445c7181aa4ecd75ee127a4446f399d6922b177805a695b8a3290ce44a4c06a6', '1a90788df8d89ad85aca1a0382bc4e07b129397596060d74e90f0aa4286e84c8', '2025-11-23 14:52:33'),
(68, 66, '445c7181aa4ecd75ee127a4446f399d6922b177805a695b8a3290ce44a4c06a6', '16a2034b7b7f8059eb73b4b02845b5623983cd5bb445e11ba49e750b39bf08a0', 'f5d4af6422c067f76dd5c6fa5235c38287b919a5b3535f548eb79e1aaa840e66', '2025-11-23 19:50:50'),
(69, 67, '16a2034b7b7f8059eb73b4b02845b5623983cd5bb445e11ba49e750b39bf08a0', '737cb2e234c535e9032083d9666c4ad006d8b321ee8ffff14239ad4fe72b8e53', 'f43510d6efd7b7b038d95768c95f63d3a5e01dafcb8667b18cebaec368c1640a', '2025-11-23 19:58:33'),
(70, 68, '737cb2e234c535e9032083d9666c4ad006d8b321ee8ffff14239ad4fe72b8e53', '5ce65df78b00ec2923b5b6da8e3e921269e458adeb53823a79398e97e2cd6ebb', '55990d42a294d0fc629433656a74d2486ee413a8bb1dd3863ae4f59c9d6f608f', '2025-11-23 19:58:37'),
(71, 69, '5ce65df78b00ec2923b5b6da8e3e921269e458adeb53823a79398e97e2cd6ebb', '39831f4a30282a3887156315e79d484358ba10cc6c0a399123feb77b8c571a34', 'a79bbe27aae16ce0dc4199281302342a2e3abde9c3b265b5333f50d337376b88', '2025-11-28 17:25:11'),
(72, 69, '39831f4a30282a3887156315e79d484358ba10cc6c0a399123feb77b8c571a34', 'fe6656e86d087833de9564be8a955147efac3c87894f7d28a2e61490c03917ee', '8d55b4f9073371ee6266f440de610b510a9faa91528a70c12b70cdb27aeec0bf', '2025-11-30 21:06:05'),
(73, 61, 'fe6656e86d087833de9564be8a955147efac3c87894f7d28a2e61490c03917ee', 'ca147d4a3a96c40070883005ff3796c342f64a15e06ea3bc9717d4f5aacb1e86', 'fa7446bc9bb15887da01f46f40aaae67abaebf232df0bd8f29df4f0557066d07', '2025-11-30 21:09:09'),
(74, 60, 'ca147d4a3a96c40070883005ff3796c342f64a15e06ea3bc9717d4f5aacb1e86', '10f2600d606b78e02d8b39ef58de087987a1c2b914ee9ea7be69de47939a1067', 'b2658294eb73b2eeca05d36573d4de0f61af0d497b62b069e0e67327d7033a75', '2025-11-30 21:14:59');

-- --------------------------------------------------------

--
-- Table structure for table `events`
--

CREATE TABLE `events` (
  `event_id` int(11) NOT NULL,
  `event_name` varchar(200) NOT NULL,
  `venue` varchar(200) NOT NULL,
  `event_date` datetime NOT NULL,
  `status` enum('OPEN','CLOSED') DEFAULT 'OPEN',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `event_image` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `events`
--

INSERT INTO `events` (`event_id`, `event_name`, `venue`, `event_date`, `status`, `created_at`, `event_image`) VALUES
(6, 'World Tour Concert Cold Play 2026', 'Bukit Jalil Stadium', '2026-02-15 20:30:00', 'OPEN', '2025-11-15 12:31:15', 'event_images/1763209875965_ColdplayPoster.png'),
(7, 'World Tour GEM Concert 2026', 'Singapore National Stadium', '2026-01-15 22:00:00', 'OPEN', '2025-11-15 12:44:09', 'event_images/1763210649131_GEMPoster.png'),
(8, 'Las Vegas Ed Sheeran Concert', 'Allegiant Stadium, Las Vegas', '2026-07-18 19:45:00', 'OPEN', '2025-11-15 12:45:29', 'event_images/1763210729599_EdsheeranPoster1.png'),
(9, 'Singapore Concert Gary Chaw 2026', 'Singapore Resorts World Ballroom', '2026-01-17 20:00:00', 'OPEN', '2025-11-15 12:46:35', 'event_images/1763210795571_GaryPoster.png'),
(10, 'World Tour JJ20 JJ Lin 2026', 'National Stadium Bukit Jalil, Kuala Lumpur', '2026-05-10 20:00:00', 'OPEN', '2025-11-15 12:47:54', 'event_images/1763210874426_JJPoster.png'),
(11, 'Singapore Concert JJ Lin WeWill 2026', 'Singapore National Stadium', '2026-04-08 21:00:00', 'OPEN', '2025-11-15 12:49:00', 'event_images/1763210940667_JJPoster2.png'),
(12, 'World Tour Wu 2026', 'Bukit Jalil', '2025-12-11 20:33:00', 'OPEN', '2025-11-18 05:33:37', 'event_images/1763444017809_Poster2.png');

-- --------------------------------------------------------

--
-- Table structure for table `event_seats`
--

CREATE TABLE `event_seats` (
  `seat_type_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  `seat_type` varchar(100) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `total_qty` int(11) NOT NULL,
  `remaining_qty` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `event_seats`
--

INSERT INTO `event_seats` (`seat_type_id`, `event_id`, `seat_type`, `price`, `total_qty`, `remaining_qty`) VALUES
(4, 11, 'VIP 1', 699.00, 30, 28),
(5, 11, 'VIP 2', 599.00, 25, 24),
(6, 11, 'Normal Seat', 399.00, 50, 48),
(7, 11, 'Back Seat', 259.00, 50, 45),
(8, 10, 'Rock Zone', 399.00, 30, 27),
(9, 10, 'Normal 1', 499.00, 35, 34),
(10, 10, 'Normal 2', 289.00, 45, 38),
(11, 9, 'VIP ', 699.00, 40, 37),
(12, 9, 'Normal', 399.00, 50, 49),
(13, 9, 'Back Seat', 188.00, 60, 56),
(14, 8, 'VIP', 599.00, 35, 30),
(15, 8, 'Normal', 399.00, 45, 45),
(16, 8, 'Back Seat', 288.00, 50, 44),
(17, 7, 'Rock Zone', 399.00, 50, 50),
(18, 7, 'VIP', 599.00, 40, 38),
(19, 7, 'Normal ', 388.00, 60, 55),
(20, 6, 'Rock Zone', 399.00, 40, 36),
(21, 6, 'VIP', 599.00, 40, 38),
(22, 6, 'Normal ', 388.00, 45, 39);

-- --------------------------------------------------------

--
-- Table structure for table `support_tickets`
--

CREATE TABLE `support_tickets` (
  `ticket_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `category` enum('PAYMENT','TICKET','ACCOUNT','QR','OTHER') DEFAULT 'OTHER',
  `status` enum('OPEN','IN_PROGRESS','CLOSED') DEFAULT 'OPEN',
  `description` text NOT NULL,
  `admin_reply` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `support_tickets`
--

INSERT INTO `support_tickets` (`ticket_id`, `user_id`, `subject`, `category`, `status`, `description`, `admin_reply`, `created_at`, `updated_at`) VALUES
(1, 1, 'My Ticket Cant sell in marketplace', 'TICKET', 'CLOSED', 'my ticket cant sell', 'cant solve', '2025-11-19 22:38:57', '2025-11-19 23:28:07'),
(2, 1, 'Account getting hacked', 'ACCOUNT', 'IN_PROGRESS', 'hohoho', 'hohoho', '2025-11-19 23:38:05', '2025-11-19 23:38:41');

-- --------------------------------------------------------

--
-- Table structure for table `tickets`
--

CREATE TABLE `tickets` (
  `ticket_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  `event_name` varchar(200) NOT NULL,
  `seat_type` varchar(100) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `purchase_time` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` enum('ACTIVE','LISTED','USED','REJECT') NOT NULL,
  `block_hash` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tickets`
--

INSERT INTO `tickets` (`ticket_id`, `user_id`, `event_id`, `event_name`, `seat_type`, `price`, `purchase_time`, `status`, `block_hash`) VALUES
(55, 1, 6, 'World Tour Concert Cold Play 2026', 'Rock Zone', 399.00, '2025-11-23 14:48:22', 'ACTIVE', '2b4c091b400a19f332d74cfeb28051bfd8f5f4d303aff633a47e48a1568d8085'),
(56, 2, 9, 'Singapore Concert Gary Chaw 2026', 'Back Seat', 188.00, '2025-11-23 14:48:41', 'REJECT', '6ef973feb7da743f1346a0e5277e084cecf977f72da0d7007dfec658349aa2e3'),
(57, 1, 11, 'Singapore Concert JJ Lin WeWill 2026', 'Normal Seat', 399.00, '2025-11-23 14:48:45', 'ACTIVE', '542621363e93c568d16a2a420b0f2f458e1fa8bbc9b211963aad509ea6cecdd1'),
(58, 4, 10, 'World Tour JJ20 JJ Lin 2026', 'Normal 2', 289.00, '2025-11-23 14:52:33', 'USED', '445c7181aa4ecd75ee127a4446f399d6922b177805a695b8a3290ce44a4c06a6'),
(59, 2, 11, 'Singapore Concert JJ Lin WeWill 2026', 'Back Seat', 259.00, '2025-11-23 14:49:31', 'ACTIVE', 'eff3fe330cbfb198bde260b63d8a2b26c2f9c8aeefdfc49c86457e5e7085d460'),
(60, 1, 6, 'World Tour Concert Cold Play 2026', 'Rock Zone', 399.00, '2025-11-30 21:14:59', 'ACTIVE', '10f2600d606b78e02d8b39ef58de087987a1c2b914ee9ea7be69de47939a1067'),
(61, 1, 7, 'World Tour GEM Concert 2026', 'Normal ', 388.00, '2025-11-30 21:09:09', 'ACTIVE', 'ca147d4a3a96c40070883005ff3796c342f64a15e06ea3bc9717d4f5aacb1e86'),
(62, 3, 11, 'Singapore Concert JJ Lin WeWill 2026', 'VIP 2', 599.00, '2025-11-23 14:50:02', 'ACTIVE', '7bcff1abfe32c6a3afb57a8ad86a2802a9c576277a3ce5e53498c69a216aa4cc'),
(63, 3, 6, 'World Tour Concert Cold Play 2026', 'VIP', 599.00, '2025-11-23 14:50:06', 'ACTIVE', 'a69125c3ae7cfd03dbbf795b88bd55a333f4cc73c174d7a6679182552ee5e7de'),
(64, 4, 8, 'Las Vegas Ed Sheeran Concert', 'Back Seat', 288.00, '2025-11-23 14:52:32', 'ACTIVE', '3a026b4ff322df29230cbdf3dc0f58f2632b2e66dd26c34c2ae6c82f3eee3f43'),
(65, 3, 7, 'World Tour GEM Concert 2026', 'VIP', 599.00, '2025-11-23 14:50:13', 'ACTIVE', '42150947cdcb5fdbff3d2d14b62d137d2616150a75699e05d7b5759a2797c8f5'),
(66, 1, 11, 'Singapore Concert JJ Lin WeWill 2026', 'Back Seat', 259.00, '2025-11-23 19:50:50', 'USED', '16a2034b7b7f8059eb73b4b02845b5623983cd5bb445e11ba49e750b39bf08a0'),
(67, 1, 9, 'Singapore Concert Gary Chaw 2026', 'Back Seat', 188.00, '2025-11-23 19:58:33', 'ACTIVE', '737cb2e234c535e9032083d9666c4ad006d8b321ee8ffff14239ad4fe72b8e53'),
(68, 1, 6, 'World Tour Concert Cold Play 2026', 'Normal ', 388.00, '2025-11-23 19:58:37', 'ACTIVE', '5ce65df78b00ec2923b5b6da8e3e921269e458adeb53823a79398e97e2cd6ebb'),
(69, 2, 9, 'Singapore Concert Gary Chaw 2026', 'VIP ', 699.00, '2025-11-30 21:06:05', 'LISTED', 'fe6656e86d087833de9564be8a955147efac3c87894f7d28a2e61490c03917ee');

-- --------------------------------------------------------

--
-- Table structure for table `ticket_resale_listings`
--

CREATE TABLE `ticket_resale_listings` (
  `listing_id` int(11) NOT NULL,
  `ticket_id` int(11) NOT NULL,
  `seller_id` int(11) NOT NULL,
  `buyer_id` int(11) DEFAULT NULL,
  `event_id` int(11) NOT NULL,
  `seat_type` varchar(100) NOT NULL,
  `original_price` decimal(10,2) NOT NULL,
  `listing_price` decimal(10,2) NOT NULL,
  `status` enum('LISTED','SOLD','CANCELLED') DEFAULT 'LISTED',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `sold_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `ticket_resale_listings`
--

INSERT INTO `ticket_resale_listings` (`listing_id`, `ticket_id`, `seller_id`, `buyer_id`, `event_id`, `seat_type`, `original_price`, `listing_price`, `status`, `created_at`, `sold_at`) VALUES
(19, 64, 3, 4, 8, 'Back Seat', 288.00, 288.00, 'SOLD', '2025-11-23 14:50:28', '2025-11-23 14:52:32'),
(20, 66, 3, 1, 11, 'Back Seat', 259.00, 255.00, 'SOLD', '2025-11-23 14:51:21', '2025-11-23 19:50:50'),
(21, 58, 1, 4, 10, 'Normal 2', 289.00, 288.00, 'SOLD', '2025-11-23 14:51:45', '2025-11-23 14:52:33'),
(22, 67, 1, NULL, 9, 'Back Seat', 188.00, 188.00, 'CANCELLED', '2025-11-24 14:08:35', NULL),
(23, 69, 1, 2, 9, 'VIP ', 699.00, 699.00, 'SOLD', '2025-11-28 17:25:56', '2025-11-30 21:06:05'),
(24, 61, 2, 1, 7, 'Normal ', 388.00, 388.00, 'SOLD', '2025-11-30 21:06:32', '2025-11-30 21:09:09'),
(25, 69, 2, NULL, 9, 'VIP ', 699.00, 688.00, 'LISTED', '2025-11-30 21:06:39', NULL),
(26, 60, 2, 1, 6, 'Rock Zone', 399.00, 388.00, 'SOLD', '2025-11-30 21:06:44', '2025-11-30 21:14:59');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `fullname` varchar(100) NOT NULL,
  `phone` varchar(15) NOT NULL,
  `email` varchar(100) NOT NULL,
  `dob` date NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('USER','ADMIN') NOT NULL DEFAULT 'USER',
  `identity_status` enum('PENDING','VERIFIED','REJECTED') DEFAULT 'PENDING'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `fullname`, `phone`, `email`, `dob`, `password`, `role`, `identity_status`) VALUES
(1, 'yongkek', '0194245333', 'yk@gmail.com', '1998-12-18', '123123123', 'USER', 'VERIFIED'),
(2, 'Clement Chew', '0185587720', 'clement@gmail.com', '2024-10-16', 'hoho12345', 'USER', 'VERIFIED'),
(3, 'Senghee', '0175037072', 'seng@gmail.com', '2002-12-12', '321321321', 'USER', 'VERIFIED'),
(4, 'Jialoon123', '018123456', 'loon@gmail.com', '2002-12-12', 'Loonloon@2000', 'USER', 'VERIFIED'),
(5, 'yeapweijian', '019321321', 'yeap@gmail.com', '2001-12-12', 'Yeapweijian@2002', 'USER', 'PENDING'),
(6, 'AdminTeh', '0194578847', 'admin1@gmail.com', '1995-12-12', 'Admin@12345', 'ADMIN', 'PENDING'),
(7, 'WeiChuen', '0193345633', 'lohwei@gmail.com', '2000-12-12', 'Weichuen@321', 'USER', 'PENDING');

-- --------------------------------------------------------

--
-- Table structure for table `user_identity`
--

CREATE TABLE `user_identity` (
  `identity_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `id_photo_path` varchar(255) NOT NULL,
  `face_photo_path` varchar(255) NOT NULL,
  `verified_by` int(11) DEFAULT NULL,
  `status` enum('PENDING','APPROVED','REJECTED') DEFAULT 'PENDING',
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_identity`
--

INSERT INTO `user_identity` (`identity_id`, `user_id`, `id_photo_path`, `face_photo_path`, `verified_by`, `status`, `created_at`, `updated_at`) VALUES
(5, 1, '1_id_1764425767914.jpg', '1_face_1764425767922.jpg', 6, 'APPROVED', '2025-11-29 22:16:07', '2025-11-29 22:16:47'),
(6, 2, '2_id_1764425881235.jpg', '2_face_1764425881237.jpg', 6, 'APPROVED', '2025-11-29 22:18:01', '2025-11-29 22:19:23'),
(7, 3, '3_id_1764425926716.jpg', '3_face_1764425926718.jpg', 6, 'APPROVED', '2025-11-29 22:18:46', '2025-11-29 22:19:31'),
(8, 4, '4_id_1764444611986.jpg', '4_face_1764444611990.jpg', 6, 'APPROVED', '2025-11-30 03:30:11', '2025-11-30 03:30:51');

-- --------------------------------------------------------

--
-- Table structure for table `wallets`
--

CREATE TABLE `wallets` (
  `wallet_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `wallet_address` varchar(150) NOT NULL,
  `balance` decimal(18,6) DEFAULT 0.000000,
  `status` enum('ACTIVE','DISABLED') DEFAULT 'ACTIVE'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `wallet_topup`
--

CREATE TABLE `wallet_topup` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `status` varchar(20) DEFAULT 'PENDING',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `blockchain`
--
ALTER TABLE `blockchain`
  ADD PRIMARY KEY (`block_id`);

--
-- Indexes for table `events`
--
ALTER TABLE `events`
  ADD PRIMARY KEY (`event_id`);

--
-- Indexes for table `event_seats`
--
ALTER TABLE `event_seats`
  ADD PRIMARY KEY (`seat_type_id`),
  ADD KEY `event_id` (`event_id`);

--
-- Indexes for table `support_tickets`
--
ALTER TABLE `support_tickets`
  ADD PRIMARY KEY (`ticket_id`),
  ADD KEY `fk_supportticket_user` (`user_id`);

--
-- Indexes for table `tickets`
--
ALTER TABLE `tickets`
  ADD PRIMARY KEY (`ticket_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `event_id` (`event_id`);

--
-- Indexes for table `ticket_resale_listings`
--
ALTER TABLE `ticket_resale_listings`
  ADD PRIMARY KEY (`listing_id`),
  ADD KEY `fk_listing_ticket` (`ticket_id`),
  ADD KEY `fk_listing_seller` (`seller_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user_identity`
--
ALTER TABLE `user_identity`
  ADD PRIMARY KEY (`identity_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `wallets`
--
ALTER TABLE `wallets`
  ADD PRIMARY KEY (`wallet_id`),
  ADD KEY `fk_wallet_user` (`user_id`);

--
-- Indexes for table `wallet_topup`
--
ALTER TABLE `wallet_topup`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `blockchain`
--
ALTER TABLE `blockchain`
  MODIFY `block_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=75;

--
-- AUTO_INCREMENT for table `events`
--
ALTER TABLE `events`
  MODIFY `event_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `event_seats`
--
ALTER TABLE `event_seats`
  MODIFY `seat_type_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `support_tickets`
--
ALTER TABLE `support_tickets`
  MODIFY `ticket_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `tickets`
--
ALTER TABLE `tickets`
  MODIFY `ticket_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=70;

--
-- AUTO_INCREMENT for table `ticket_resale_listings`
--
ALTER TABLE `ticket_resale_listings`
  MODIFY `listing_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `user_identity`
--
ALTER TABLE `user_identity`
  MODIFY `identity_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `wallets`
--
ALTER TABLE `wallets`
  MODIFY `wallet_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `wallet_topup`
--
ALTER TABLE `wallet_topup`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `event_seats`
--
ALTER TABLE `event_seats`
  ADD CONSTRAINT `event_seats_ibfk_1` FOREIGN KEY (`event_id`) REFERENCES `events` (`event_id`);

--
-- Constraints for table `support_tickets`
--
ALTER TABLE `support_tickets`
  ADD CONSTRAINT `fk_supportticket_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `tickets`
--
ALTER TABLE `tickets`
  ADD CONSTRAINT `tickets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `tickets_ibfk_2` FOREIGN KEY (`event_id`) REFERENCES `events` (`event_id`);

--
-- Constraints for table `ticket_resale_listings`
--
ALTER TABLE `ticket_resale_listings`
  ADD CONSTRAINT `fk_listing_seller` FOREIGN KEY (`seller_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_listing_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`ticket_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
