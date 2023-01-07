CREATE TABLE `ban_system_bans` (
  `name` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `liveid` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `xbl` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `hwid` varchar(255) COLLATE utf8mb4_bin NOT NULL,
  `ip` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `discord` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `license` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `steamid` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `date` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `banneduntil` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `bannedby` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `reason` varchar(255) COLLATE utf8mb4_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

ALTER TABLE `ban_system_bans`
  ADD PRIMARY KEY (`hwid`);
COMMIT;