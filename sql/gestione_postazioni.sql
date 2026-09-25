CREATE DATABASE IF NOT EXISTS `gestione_postazioni` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `gestione_postazioni`;

-- --------------------------------------------------------

--
-- Struttura della tabella `piano`
--

CREATE TABLE `piano` (
  `id` int NOT NULL,
  `descrizione` varchar(250) NOT NULL,
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
-- AUTO_INCREMENT per la tabella `un_postazione_stato`
--
ALTER TABLE `un_postazione_stato`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT per la tabella `zona`
--
ALTER TABLE `zona`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;