CREATE DATABASE IF NOT EXISTS `gestione_postazioni` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `gestione_postazioni`;

-- --------------------------------------------------------

--
-- Struttura della tabella `piano`
--

CREATE TABLE `piano` (
  `id` int NOT NULL,
  `descrizione` varchar(250) NOT NULL,
  `path_mappa` varchar(250) DEFAULT NULL,
  `attivo` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Struttura della tabella `postazione`
--

CREATE TABLE `postazione` (
  `id` int NOT NULL,
  `id_piano` int NOT NULL,
  `id_zona` int NOT NULL,
  `codice_postazione` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'PDL',
  `p_pos_x` decimal(6,3) NOT NULL COMMENT 'percentuale per gestire ogni monitor',
  `p_pos_y` decimal(6,3) NOT NULL COMMENT 'percentuale per gestire ogni monitor',
  `id_stato` int NOT NULL DEFAULT '1',
  `attivo` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Struttura della tabella `stato_postazione`
--

CREATE TABLE `stato_postazione` (
  `id` int NOT NULL,
  `descrizione` varchar(250) NOT NULL,
  `colore` varchar(250) NOT NULL,
  `attivo` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dump dei dati per la tabella `stato_postazione`
--

INSERT INTO `stato_postazione` (`id`, `descrizione`, `colore`, `attivo`) VALUES
(1, 'Libero', 'green', 1),
(2, 'Assegnato', 'red', 1),
(3, 'Guasto/Indisponibile', 'gray', 1);

-- --------------------------------------------------------

--
-- Struttura della tabella `system_chiave_cifratura`
--

CREATE TABLE `system_chiave_cifratura` (
  `id` int NOT NULL,
  `chiave` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `metodo` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `ivector` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `data_attivazione` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `attivo` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struttura della tabella `system_login_utente`
--

CREATE TABLE `system_login_utente` (
  `id` int NOT NULL,
  `id_utente` int NOT NULL,
  `id_ruolo` int NOT NULL,
  `username` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `primo_accesso` int NOT NULL DEFAULT '1',
  `token` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `data_cambio_password` datetime DEFAULT NULL,
  `flag_reset` int NOT NULL DEFAULT '0',
  `data_reset` datetime DEFAULT NULL,
  `flag_disabilitato` int NOT NULL DEFAULT '0',
  `data_disabilitazione` datetime DEFAULT NULL,
  `data_ultimo_accesso` datetime DEFAULT NULL,
  `n_tentativi_errati` int NOT NULL DEFAULT '0',
  `data_spedizione` datetime DEFAULT NULL,
  `flg_spedizione` int DEFAULT NULL,
  `flg_cambio_psw` int DEFAULT NULL,
  `attivo` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struttura della tabella `system_log_accessi`
--

CREATE TABLE `system_log_accessi` (
  `id` int NOT NULL,
  `id_utente` int NOT NULL,
  `id_ruolo` int NOT NULL,
  `data_login` datetime NOT NULL,
  `ip_address` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `data_logout` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Struttura della tabella `system_log_operazioni`
--

CREATE TABLE `system_log_operazioni` (
  `id` int NOT NULL,
  `id_modulo` int NOT NULL,
  `id_utente` int NOT NULL,
  `id_tipo_operazione` int NOT NULL COMMENT '1=insert,2,update,3=delete',
  `query` text NOT NULL,
  `data_operazione` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Struttura della tabella `system_mittente`
--

CREATE TABLE `system_mittente` (
  `id` int NOT NULL,
  `email` varchar(150) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `nome_mittente` varchar(150) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `host` varchar(150) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `port` int NOT NULL,
  `smtp_secure` varchar(150) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `password` varchar(150) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `attivo` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Struttura della tabella `system_modulo_applicativo`
--

CREATE TABLE `system_modulo_applicativo` (
  `id` int NOT NULL,
  `sigla_pagina` varchar(50) NOT NULL,
  `pagina` varchar(150) NOT NULL,
  `descrizione` varchar(250) NOT NULL,
  `attivo` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dump dei dati per la tabella `system_modulo_applicativo`
--

INSERT INTO `system_modulo_applicativo` (`id`, `sigla_pagina`, `pagina`, `descrizione`, `attivo`) VALUES
(1, 'configurazione', 'configura/index.php', 'Dashboard dei moduli di configurazione', 1),
(2, 'piano', 'configura/piano.php', 'Anagafica dei piani e relative mappe', 1),
(3, 'zona', 'configura/zona.php', 'Anagafica dele zone', 1),
(4, 'stato_postazione', 'configura/stato_postazione.php', 'Anagafica degli stati', 1),
(5, 'postazione', 'configura/postazione.php', 'Anagrafica Postazioni', 1),
(6, 'utenti', 'admin/utenti.php', 'Gestione Utenti e Ruoli', 1),
(7, 'log_accessi', 'admin/log-accessi.php', 'Log Accessi', 1),
(8, 'storico_psw', 'admin/storico-psw.php', 'Storico Password', 1),
(9, 'log_operazioni', 'admin/log-operazioni.php', 'Log Operazioni', 1),
(10, 'parametri_sistema', 'admin/parametri.php', 'Parametri Sistema', 1),
(11, 'sistema_ruolo', 'admin/sistema-ruolo.php', 'Ruoli Sistema', 1),
(12, 'postazioni', 'postazioni/mappa_postazioni.php', 'Gestione Postazioni', 1),
(13, 'storico_movimentazioni', 'postazioni/storico_mappa_postazioni.php', 'Storico Movimentazioni', 1);

-- --------------------------------------------------------

--
-- Struttura della tabella `system_parametri_contatori`
--

CREATE TABLE `system_parametri_contatori` (
  `id` int NOT NULL,
  `nome_parametro` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `valore` int NOT NULL,
  `attivo` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `system_parametri_contatori`
--

INSERT INTO `system_parametri_contatori` (`id`, `nome_parametro`, `valore`, `attivo`) VALUES
(1, 'UguaglianzaPassword', 5, 1),
(2, 'TentativiErrati', 3, 1),
(3, 'MesiInattivita', 6, 1),
(4, 'ModificaPassword', 180, 1);

-- --------------------------------------------------------

--
-- Struttura della tabella `system_ruolo`
--

CREATE TABLE `system_ruolo` (
  `id` int NOT NULL,
  `ruolo` varchar(50) NOT NULL,
  `descrizione` varchar(250) DEFAULT NULL,
  `attivo` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dump dei dati per la tabella `system_ruolo`
--

INSERT INTO `system_ruolo` (`id`, `ruolo`, `descrizione`, `attivo`) VALUES
(1, 'admin', 'può fare tutto', 1),
(2, 'super_operatore', 'può accedere al pannello di configurazione e gestire le postazioni', 1),
(3, 'operatore', 'può operare sulle postazioni', 1),
(4, 'audit', 'come il super_operatore ma in sola visualizzazione', 1);

-- --------------------------------------------------------

--
-- Struttura della tabella `system_ruolo_modulo`
--

CREATE TABLE `system_ruolo_modulo` (
  `id` int NOT NULL,
  `id_ruolo` int NOT NULL,
  `id_modulo` int NOT NULL,
  `visualizza` int NOT NULL DEFAULT '0',
  `modifica` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dump dei dati per la tabella `system_ruolo_modulo`
--

INSERT INTO `system_ruolo_modulo` (`id`, `id_ruolo`, `id_modulo`, `visualizza`, `modifica`) VALUES
(1, 1, 1, 1, 1),
(2, 1, 2, 1, 1),
(3, 1, 3, 1, 1),
(4, 1, 4, 1, 1),
(5, 1, 5, 1, 1),
(6, 1, 6, 1, 1),
(7, 1, 7, 1, 1),
(8, 1, 8, 1, 1),
(9, 1, 9, 1, 1),
(10, 1, 10, 1, 1),
(11, 1, 11, 1, 1),
(12, 1, 12, 1, 1),
(13, 1, 13, 1, 1),
(14, 2, 1, 1, 1),
(15, 2, 2, 1, 1),
(16, 2, 3, 1, 1),
(17, 2, 4, 1, 1),
(18, 2, 5, 1, 1),
(19, 2, 12, 1, 1),
(20, 3, 12, 1, 1),
(21, 4, 1, 1, 0),
(22, 4, 2, 1, 0),
(23, 4, 3, 1, 0),
(24, 4, 4, 1, 0),
(25, 4, 5, 1, 0),
(26, 4, 12, 1, 0);

-- --------------------------------------------------------

--
-- Struttura della tabella `system_storico_psw`
--

CREATE TABLE `system_storico_psw` (
  `id` int NOT NULL,
  `id_utente` int NOT NULL,
  `id_ruolo` int NOT NULL,
  `psw` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `data_cambio_psw` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struttura della tabella `system_token_mail`
--

CREATE TABLE `system_token_mail` (
  `id` int NOT NULL,
  `refresh_token` varchar(2000) NOT NULL,
  `client_id` varchar(250) NOT NULL,
  `client_secret` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struttura della tabella `system_utente`
--

CREATE TABLE `system_utente` (
  `id` int NOT NULL,
  `nome` varchar(100) NOT NULL,
  `cognome` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `attivo` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Struttura della tabella `un_asset_postazione`
--

CREATE TABLE `un_asset_postazione` (
  `id` int NOT NULL,
  `id_postazione` int NOT NULL,
  `seriale` varchar(100) NOT NULL,
  `id_asset` int NOT NULL DEFAULT '0',
  `data_associazione` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `id_assegnatario` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Struttura della tabella `un_postazione_stato`
--

CREATE TABLE `un_postazione_stato` (
  `id` int NOT NULL,
  `id_postazione` int NOT NULL,
  `id_stato` int NOT NULL,
  `data_stato` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `id_operatore` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Struttura della tabella `un_storico_asset_postazione`
--

CREATE TABLE `un_storico_asset_postazione` (
  `id` int NOT NULL,
  `id_postazione` int NOT NULL,
  `seriale` varchar(100) NOT NULL,
  `id_asset` int NOT NULL DEFAULT '0',
  `data_associazione` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `id_assegnatario` int NOT NULL,
  `data_fine_assegnazione` datetime DEFAULT NULL,
  `id_modificatore` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Struttura della tabella `zona`
--

CREATE TABLE `zona` (
  `id` int NOT NULL,
  `descrizione` varchar(250) NOT NULL,
  `z_pos_x` decimal(6,3) NOT NULL COMMENT 'percentuale per gestire ogni monitor',
  `z_pos_y` decimal(6,3) NOT NULL COMMENT 'percentuale per gestire ogni monitor',
  `attivo` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Indici per le tabelle scaricate
--

--
-- Indici per le tabelle `piano`
--
ALTER TABLE `piano`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `path_mappa` (`path_mappa`),
  ADD KEY `attivo` (`attivo`);

--
-- Indici per le tabelle `postazione`
--
ALTER TABLE `postazione`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codice_postazione` (`codice_postazione`),
  ADD KEY `id_piano` (`id_piano`),
  ADD KEY `attivo` (`attivo`),
  ADD KEY `id_zona` (`id_zona`),
  ADD KEY `id_stato` (`id_stato`);

--
-- Indici per le tabelle `stato_postazione`
--
ALTER TABLE `stato_postazione`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `colore` (`colore`),
  ADD KEY `attivo` (`attivo`);

--
-- Indici per le tabelle `system_chiave_cifratura`
--
ALTER TABLE `system_chiave_cifratura`
  ADD PRIMARY KEY (`id`);

--
-- Indici per le tabelle `system_login_utente`
--
ALTER TABLE `system_login_utente`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`) USING BTREE,
  ADD KEY `id_utente` (`id_utente`),
  ADD KEY `id_ruolo` (`id_ruolo`),
  ADD KEY `attivo` (`attivo`);

--
-- Indici per le tabelle `system_log_accessi`
--
ALTER TABLE `system_log_accessi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_utente` (`id_utente`) USING BTREE,
  ADD KEY `id_ruolo` (`id_ruolo`) USING BTREE;

--
-- Indici per le tabelle `system_log_operazioni`
--
ALTER TABLE `system_log_operazioni`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_modulo` (`id_modulo`),
  ADD KEY `id_utente` (`id_utente`),
  ADD KEY `id_tipo_operazione` (`id_tipo_operazione`),
  ADD KEY `data_operazione` (`data_operazione`);

--
-- Indici per le tabelle `system_mittente`
--
ALTER TABLE `system_mittente`
  ADD PRIMARY KEY (`id`);

--
-- Indici per le tabelle `system_modulo_applicativo`
--
ALTER TABLE `system_modulo_applicativo`
  ADD PRIMARY KEY (`id`),
  ADD KEY `attivo` (`attivo`),
  ADD KEY `sigla_pagina` (`sigla_pagina`);

--
-- Indici per le tabelle `system_parametri_contatori`
--
ALTER TABLE `system_parametri_contatori`
  ADD PRIMARY KEY (`id`);

--
-- Indici per le tabelle `system_ruolo`
--
ALTER TABLE `system_ruolo`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ruolo` (`ruolo`),
  ADD KEY `attivo` (`attivo`);

--
-- Indici per le tabelle `system_ruolo_modulo`
--
ALTER TABLE `system_ruolo_modulo`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ruolo_modulo` (`id_ruolo`,`id_modulo`),
  ADD KEY `id_ruolo` (`id_ruolo`),
  ADD KEY `id_modulo` (`id_modulo`);

--
-- Indici per le tabelle `system_storico_psw`
--
ALTER TABLE `system_storico_psw`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_utente` (`id_utente`),
  ADD KEY `id_ruolo` (`id_ruolo`);

--
-- Indici per le tabelle `system_token_mail`
--
ALTER TABLE `system_token_mail`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `client_id_2` (`client_id`),
  ADD UNIQUE KEY `client_secret` (`client_secret`),
  ADD KEY `refresh_token` (`refresh_token`(1024)),
  ADD KEY `client_id` (`client_id`);

--
-- Indici per le tabelle `system_utente`
--
ALTER TABLE `system_utente`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `attivo` (`attivo`);

--
-- Indici per le tabelle `un_asset_postazione`
--
ALTER TABLE `un_asset_postazione`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_postazione` (`id_postazione`,`id_asset`),
  ADD KEY `id_assegnatario` (`id_assegnatario`);

--
-- Indici per le tabelle `un_postazione_stato`
--
ALTER TABLE `un_postazione_stato`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_postazione` (`id_postazione`),
  ADD KEY `id_stato` (`id_stato`),
  ADD KEY `id_operatore` (`id_operatore`),
  ADD KEY `data_stato` (`data_stato`),
  ADD KEY `idx_postazione_data_stato` (`id_postazione`,`data_stato`);

--
-- Indici per le tabelle `un_storico_asset_postazione`
--
ALTER TABLE `un_storico_asset_postazione`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_postazione` (`id_postazione`,`id_asset`),
  ADD KEY `id_assegnatario` (`id_assegnatario`),
  ADD KEY `data_fine_assegnazione` (`data_fine_assegnazione`),
  ADD KEY `id_modificatore` (`id_modificatore`),
  ADD KEY `idx_postazione_data` (`id_postazione`,`data_associazione`),
  ADD KEY `idx_postazione_attivo` (`id_postazione`,`data_fine_assegnazione`);

--
-- Indici per le tabelle `zona`
--
ALTER TABLE `zona`
  ADD PRIMARY KEY (`id`),
  ADD KEY `attivo` (`attivo`);

--
-- AUTO_INCREMENT per le tabelle scaricate
--

--
-- AUTO_INCREMENT per la tabella `piano`
--
ALTER TABLE `piano`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT per la tabella `postazione`
--
ALTER TABLE `postazione`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT per la tabella `stato_postazione`
--
ALTER TABLE `stato_postazione`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT per la tabella `system_chiave_cifratura`
--
ALTER TABLE `system_chiave_cifratura`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT per la tabella `system_login_utente`
--
ALTER TABLE `system_login_utente`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT per la tabella `system_log_accessi`
--
ALTER TABLE `system_log_accessi`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT per la tabella `system_log_operazioni`
--
ALTER TABLE `system_log_operazioni`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT per la tabella `system_mittente`
--
ALTER TABLE `system_mittente`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT per la tabella `system_modulo_applicativo`
--
ALTER TABLE `system_modulo_applicativo`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT per la tabella `system_parametri_contatori`
--
ALTER TABLE `system_parametri_contatori`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT per la tabella `system_ruolo`
--
ALTER TABLE `system_ruolo`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT per la tabella `system_ruolo_modulo`
--
ALTER TABLE `system_ruolo_modulo`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT per la tabella `system_storico_psw`
--
ALTER TABLE `system_storico_psw`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT per la tabella `system_utente`
--
ALTER TABLE `system_utente`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT per la tabella `un_postazione_stato`
--
ALTER TABLE `un_postazione_stato`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT per la tabella `zona`
--
ALTER TABLE `zona`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;
