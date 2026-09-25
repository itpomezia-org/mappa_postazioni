# Gestione Postazioni

## 1. Descrizione del progetto

`gestione_postazioni` è il database dell'applicazione per la gestione delle **postazioni di lavoro (PDL)** all'interno di una struttura organizzata su uno o più piani.

L'applicazione permette di:

* gestire i piani e le relative mappe;
* definire le zone presenti nei piani;
* censire le postazioni;
* rappresentare graficamente le postazioni sulla mappa;
* gestire lo stato delle postazioni;
* associare asset alle postazioni;
* mantenere lo storico delle assegnazioni degli asset;
* mantenere lo storico degli stati delle postazioni;
* gestire utenti e ruoli;
* gestire i permessi di accesso ai moduli;
* registrare gli accessi degli utenti;
* registrare le operazioni effettuate dagli utenti;
* gestire parametri di sistema;
* gestire configurazioni relative alla posta elettronica e ai sistemi di autenticazione.

---

# 2. Struttura generale

Il database è organizzato in quattro aree principali:

### Anagrafica e configurazione

* `piano`
* `zona`
* `postazione`
* `stato_postazione`

### Gestione delle postazioni

* `un_asset_postazione`
* `un_storico_asset_postazione`
* `un_postazione_stato`

### Autenticazione e autorizzazioni

* `system_utente`
* `system_login_utente`
* `system_ruolo`
* `system_ruolo_modulo`
* `system_storico_psw`

### Sistema e audit

* `system_modulo_applicativo`
* `system_log_accessi`
* `system_log_operazioni`
* `system_parametri_contatori`
* `system_mittente`
* `system_token_mail`
* `system_chiave_cifratura`

---

# 3. Anagrafiche principali

## 3.1 `piano`

Contiene i piani dell'edificio e le relative mappe.

| Campo         | Descrizione                            |
| ------------- | -------------------------------------- |
| `id`          | Identificativo univoco del piano       |
| `descrizione` | Descrizione del piano                  |
| `path_mappa`  | Percorso del file immagine della mappa |
| `attivo`      | Indica se il piano è attivo            |

`path_mappa` è univoco.

La cancellazione dei record è di tipo **logico**, tramite il campo `attivo`.

---

## 3.2 `zona`

Contiene le zone logiche utilizzate per organizzare le postazioni.

| Campo         | Descrizione                                                 |
| ------------- | ----------------------------------------------------------- |
| `id`          | Identificativo della zona                                   |
| `descrizione` | Nome/descrizione della zona                                 |
| `z_pos_x`     | Posizione X della zona sulla mappa, espressa in percentuale |
| `z_pos_y`     | Posizione Y della zona sulla mappa, espressa in percentuale |
| `attivo`      | Indica se la zona è attiva                                  |

---

## 3.3 `postazione`

Rappresenta una singola **PDL (postazione di lavoro)**.

| Campo               | Descrizione                              |
| ------------------- | ---------------------------------------- |
| `id`                | Identificativo univoco                   |
| `id_piano`          | Piano al quale appartiene la postazione  |
| `id_zona`           | Zona alla quale appartiene la postazione |
| `codice_postazione` | Codice identificativo della PDL          |
| `p_pos_x`           | Posizione X sulla mappa, in percentuale  |
| `p_pos_y`           | Posizione Y sulla mappa, in percentuale  |
| `id_stato`          | Stato corrente della postazione          |
| `attivo`            | Indica se la postazione è attiva         |

`codice_postazione` è univoco.

Le coordinate `p_pos_x` e `p_pos_y` permettono di posizionare la postazione indipendentemente dalle dimensioni effettive dell'immagine della mappa.

La cancellazione è **logica**, tramite `attivo`.

---

## 3.4 `stato_postazione`

Definisce gli stati possibili di una postazione.

Stati iniziali:

| ID | Stato                | Colore |
| -: | -------------------- | ------ |
|  1 | Libero               | green  |
|  2 | Assegnato            | red    |
|  3 | Guasto/Indisponibile | gray   |

Il campo `colore` viene utilizzato dalla rappresentazione grafica della mappa.

### Guasto

Lo stato `Guasto/Indisponibile` si riferisce **esclusivamente alla postazione fisica**.

Non rappresenta un guasto della rete, di un asset o di altri componenti.

---

# 4. Gestione degli asset

## 4.1 `un_asset_postazione`

Contiene le associazioni correnti tra asset e postazioni.

| Campo               | Descrizione                                              |
| ------------------- | -------------------------------------------------------- |
| `id`                | Identificativo dell'associazione                         |
| `id_postazione`     | Postazione alla quale è associato l'asset                |
| `seriale`           | Numero seriale dell'asset                                |
| `id_asset`          | Identificativo dell'asset nel sistema esterno/inventario |
| `data_associazione` | Data e ora dell'associazione                             |
| `id_assegnatario`   | Utente/persona assegnataria                              |

Questa tabella rappresenta la situazione **corrente**.

---

## 4.2 `un_storico_asset_postazione`

Contiene lo storico delle associazioni tra asset e postazioni.

| Campo                    | Descrizione                                    |
| ------------------------ | ---------------------------------------------- |
| `id`                     | Identificativo dello storico                   |
| `id_postazione`          | Postazione interessata                         |
| `seriale`                | Numero seriale dell'asset                      |
| `id_asset`               | Identificativo dell'asset                      |
| `data_associazione`      | Data e ora di inizio associazione              |
| `id_assegnatario`        | Assegnatario                                   |
| `data_fine_assegnazione` | Data e ora di fine associazione                |
| `id_modificatore`        | Utente che ha chiuso/modificato l'associazione |

### Regola dello storico

Un record con:

```text
data_fine_assegnazione IS NULL
```

rappresenta un'associazione ancora attiva.

Quando l'associazione termina:

```text
data_fine_assegnazione = data/ora di chiusura
id_modificatore = utente che esegue l'operazione
```

In questo modo è possibile ricostruire la storia delle movimentazioni degli asset.

---

# 5. Storico degli stati

## `un_postazione_stato`

Registra ogni variazione di stato di una postazione.

| Campo           | Descrizione                            |
| --------------- | -------------------------------------- |
| `id`            | Identificativo del record              |
| `id_postazione` | Postazione interessata                 |
| `id_stato`      | Nuovo stato                            |
| `data_stato`    | Data e ora della variazione            |
| `id_operatore`  | Utente che ha effettuato la variazione |

Esempio:

```text
PDL-001
    09:00 → Libero
    10:15 → Assegnato
    14:30 → Guasto/Indisponibile
    16:00 → Libero
```

Lo storico permette quindi di ricostruire l'evoluzione dello stato di una PDL nel tempo.

---

# 6. Utenti e autenticazione

## 6.1 `system_utente`

Contiene l'anagrafica degli utenti dell'applicazione.

| Campo     | Descrizione           |
| --------- | --------------------- |
| `id`      | Identificativo utente |
| `nome`    | Nome                  |
| `cognome` | Cognome               |
| `email`   | Email                 |
| `attivo`  | Stato dell'utente     |

L'email è univoca.

---

## 6.2 `system_login_utente`

Contiene le informazioni necessarie per l'autenticazione.

| Campo                  | Descrizione                           |
| ---------------------- | ------------------------------------- |
| `id`                   | Identificativo                        |
| `id_utente`            | Utente associato                      |
| `id_ruolo`             | Ruolo dell'utente                     |
| `username`             | Nome utente                           |
| `password_hash`        | Hash della password                   |
| `primo_accesso`        | Indica il primo accesso               |
| `token`                | Token applicativo                     |
| `data_cambio_password` | Data dell'ultimo cambio password      |
| `flag_reset`           | Stato della procedura di reset        |
| `data_reset`           | Data del reset                        |
| `flag_disabilitato`    | Indica se l'account è disabilitato    |
| `data_disabilitazione` | Data della disabilitazione            |
| `data_ultimo_accesso`  | Ultimo accesso effettuato             |
| `n_tentativi_errati`   | Numero di tentativi di accesso errati |
| `data_spedizione`      | Data di eventuale spedizione          |
| `flg_spedizione`       | Flag spedizione                       |
| `flg_cambio_psw`       | Flag cambio password                  |
| `attivo`               | Stato dell'account                    |

Lo `username` è univoco.

### Ruolo

Ogni utente ha **un solo ruolo**.

Il ruolo viene quindi memorizzato direttamente in:

```text
system_login_utente.id_ruolo
```

Non è prevista una relazione molti-a-molti tra utenti e ruoli.

---

# 7. Ruoli

## `system_ruolo`

Definisce i ruoli disponibili nell'applicazione.

Ruoli attualmente configurati:

| ID | Ruolo           | Descrizione                                                        |
| -: | --------------- | ------------------------------------------------------------------ |
|  1 | admin           | Può fare tutto                                                     |
|  2 | super_operatore | Può accedere al pannello di configurazione e gestire le postazioni |
|  3 | operatore       | Può operare sulle postazioni                                       |
|  4 | audit           | Come il super_operatore ma in sola visualizzazione                 |

---

# 8. Permessi per modulo

## `system_ruolo_modulo`

Gestisce i permessi dei ruoli sui singoli moduli applicativi.

| Campo        | Descrizione                 |
| ------------ | --------------------------- |
| `id`         | Identificativo              |
| `id_ruolo`   | Ruolo                       |
| `id_modulo`  | Modulo applicativo          |
| `visualizza` | Permesso di visualizzazione |
| `modifica`   | Permesso di modifica        |

Sono previsti esclusivamente due livelli di autorizzazione:

* `visualizza`
* `modifica`

Non esiste un permesso separato di eliminazione.

### Eliminazione logica

L'eventuale eliminazione dei dati è effettuata tramite modifica del campo:

```text
attivo = 0
```

Pertanto l'eliminazione logica viene considerata una **modifica** e non richiede un permesso `elimina`.

La coppia:

```text
id_ruolo + id_modulo
```

è univoca.

---

# 9. Moduli applicativi

## `system_modulo_applicativo`

Contiene l'elenco delle funzionalità/pagine dell'applicazione soggette a controllo degli accessi.

| ID | Sigla                  | Pagina                                    | Funzione                               |
| -: | ---------------------- | ----------------------------------------- | -------------------------------------- |
|  1 | configurazione         | `configura/index.php`                     | Dashboard dei moduli di configurazione |
|  2 | piano                  | `configura/piano.php`                     | Anagrafica dei piani e relative mappe  |
|  3 | zona                   | `configura/zona.php`                      | Anagrafica delle zone                  |
|  4 | stato_postazione       | `configura/stato_postazione.php`          | Anagrafica degli stati                 |
|  5 | postazione             | `configura/postazione.php`                | Anagrafica postazioni                  |
|  6 | utenti                 | `admin/utenti.php`                        | Gestione utenti e ruoli                |
|  7 | log_accessi            | `admin/log-accessi.php`                   | Log accessi                            |
|  8 | storico_psw            | `admin/storico-psw.php`                   | Storico password                       |
|  9 | log_operazioni         | `admin/log-operazioni.php`                | Log operazioni                         |
| 10 | parametri_sistema      | `admin/parametri.php`                     | Parametri di sistema                   |
| 11 | sistema_ruolo          | `admin/sistema-ruolo.php`                 | Ruoli di sistema                       |
| 12 | postazioni             | `postazioni/mappa_postazioni.php`         | Gestione postazioni                    |
| 13 | storico_movimentazioni | `postazioni/storico_mappa_postazioni.php` | Storico movimentazioni                 |

---

# 10. Parametri di sistema

## `system_parametri_contatori`

Contiene i parametri utilizzati dai meccanismi di sicurezza e gestione degli account.

Configurazione iniziale:

| Parametro             | Valore | Significato                                  |
| --------------------- | -----: | -------------------------------------------- |
| `UguaglianzaPassword` |      5 | Numero di password precedenti da considerare |
| `TentativiErrati`     |      3 | Numero massimo di tentativi errati           |
| `MesiInattivita`      |      6 | Periodo di inattività                        |
| `ModificaPassword`    |    180 | Periodicità del cambio password              |

I valori sono modificabili dall'applicazione in base ai permessi del ruolo.

---

# 11. Storico password

## `system_storico_psw`

Conserva lo storico delle password degli utenti tramite `password_hash`.

| Campo             | Descrizione                                      |
| ----------------- | ------------------------------------------------ |
| `id`              | Identificativo                                   |
| `id_utente`       | Utente                                           |
| `id_ruolo`        | Ruolo dell'utente al momento della registrazione |
| `psw`             | Hash della password                              |
| `data_cambio_psw` | Data e ora del cambio                            |

Lo storico viene utilizzato, tra le altre cose, per verificare il parametro `UguaglianzaPassword`.

---

# 12. Log accessi

## `system_log_accessi`

Registra gli accessi effettuati dagli utenti.

| Campo         | Descrizione                   |
| ------------- | ----------------------------- |
| `id`          | Identificativo                |
| `id_utente`   | Utente                        |
| `id_ruolo`    | Ruolo al momento dell'accesso |
| `data_login`  | Data e ora del login          |
| `ip_address`  | Indirizzo IP                  |
| `data_logout` | Data e ora del logout         |

La presenza di `id_ruolo` nel log consente di conservare il ruolo effettivo dell'utente al momento dell'accesso, anche nel caso in cui successivamente venga modificato.

---

# 13. Log operazioni

## `system_log_operazioni`

Registra le operazioni effettuate dagli utenti sui moduli applicativi.

| Campo                | Descrizione                                    |
| -------------------- | ---------------------------------------------- |
| `id`                 | Identificativo                                 |
| `id_modulo`          | Modulo sul quale viene effettuata l'operazione |
| `id_utente`          | Utente che ha effettuato l'operazione          |
| `id_tipo_operazione` | Tipo di operazione                             |
| `query`              | Informazioni relative all'operazione           |
| `data_operazione`    | Data e ora dell'operazione                     |

Tipi di operazione:

```text
1 = INSERT
2 = UPDATE
3 = DELETE
```

Nel caso dell'applicazione, l'eventuale eliminazione dei dati è prevalentemente **logica** (`attivo = 0`).

---

# 14. Configurazione email

## `system_mittente`

Contiene i parametri del mittente utilizzati dall'applicazione per l'invio delle email.

| Campo           | Descrizione                |
| --------------- | -------------------------- |
| `id`            | Identificativo             |
| `email`         | Indirizzo mittente         |
| `nome_mittente` | Nome visualizzato          |
| `host`          | Server SMTP                |
| `port`          | Porta SMTP                 |
| `smtp_secure`   | Tipo di protezione SMTP    |
| `password`      | Credenziale SMTP           |
| `attivo`        | Stato della configurazione |

**Nota di sicurezza:** le credenziali SMTP non dovrebbero essere inserite nei dump SQL del progetto o nei repository Git. È preferibile utilizzare variabili d'ambiente Docker o un sistema di secrets.

---

# 15. Token per servizi email

## `system_token_mail`

Contiene le informazioni necessarie per l'autenticazione verso eventuali servizi esterni di posta.

| Campo           | Descrizione    |
| --------------- | -------------- |
| `id`            | Identificativo |
| `refresh_token` | Refresh token  |
| `client_id`     | Client ID      |
| `client_secret` | Client secret  |

**Nota di sicurezza:** token e client secret sono informazioni riservate e non devono essere versionati nel repository.

---

# 16. Chiavi di cifratura

## `system_chiave_cifratura`

Contiene i parametri utilizzati per eventuali funzionalità di cifratura.

| Campo              | Descrizione                 |
| ------------------ | --------------------------- |
| `id`               | Identificativo              |
| `chiave`           | Chiave di cifratura         |
| `metodo`           | Metodo/algoritmo utilizzato |
| `ivector`          | IV/vector utilizzato        |
| `data_attivazione` | Data di attivazione         |
| `attivo`           | Indica la chiave attiva     |

**Nota di sicurezza:** la chiave di cifratura è un segreto applicativo. Per un ambiente Docker è preferibile gestirla tramite secrets/variabili d'ambiente anziché inserirla direttamente nel database o nel codice sorgente.

---

# 17. Regole di cancellazione

L'applicazione utilizza principalmente la **cancellazione logica**.

Le tabelle anagrafiche che prevedono il campo:

```text
attivo
```

non devono essere normalmente cancellate fisicamente.

Esempio:

```sql
UPDATE postazione
SET attivo = 0
WHERE id = ?;
```

Questo consente di:

* mantenere lo storico;
* non perdere riferimenti;
* mantenere l'audit delle operazioni;
* poter eventualmente recuperare un elemento disattivato.

Di conseguenza il sistema dei permessi utilizza:

```text
visualizza
modifica
```

e non un permesso separato `elimina`.

---

# 18. Convenzioni sui campi `attivo`

Il campo `attivo` viene utilizzato come flag logico.

```text
1 = attivo
0 = non attivo
```

È presente nelle principali anagrafiche e configurazioni.

Le query dell'applicazione dovranno quindi normalmente filtrare gli elementi attivi:

```sql
WHERE attivo = 1
```

quando si desidera visualizzare esclusivamente gli elementi utilizzabili.

---

# 19. Indici

Il database contiene indici dedicati principalmente a:

* chiavi primarie;
* campi univoci;
* collegamenti tra tabelle;
* filtri `attivo`;
* ricerche per utente;
* ricerche per postazione;
* ricerche cronologiche;
* consultazione degli storici.

In particolare:

### Storico stati

```text
(id_postazione, data_stato)
```

permette di recuperare rapidamente la cronologia di una specifica postazione.

### Storico asset

```text
(id_postazione, data_associazione)
(id_postazione, data_fine_assegnazione)
```

facilita la consultazione delle associazioni correnti e dello storico.

### Permessi

```text
(id_ruolo, id_modulo)
```

garantisce che uno stesso ruolo non possa avere più configurazioni per lo stesso modulo.

---

# 20. Flusso logico della gestione di una postazione

La relazione logica principale è:

```text
PIANO
  │
  ├── ZONA
  │     │
  │     └── POSTAZIONE
  │             │
  │             ├── STATO
  │             │
  │             ├── ASSET CORRENTI
  │             │
  │             ├── STORICO ASSET
  │             │
  │             └── STORICO STATI
  │
  └── MAPPA
```

Una postazione appartiene a un piano e a una zona, possiede uno stato corrente ed è rappresentata graficamente sulla mappa tramite coordinate percentuali.

Gli asset associati e le variazioni di stato vengono mantenuti separatamente per poter ricostruire la storia della postazione.

---

# 21. Flusso di autenticazione

Il flusso previsto è:

```text
system_utente
       │
       ▼
system_login_utente
       │
       ├── username
       ├── password_hash
       └── id_ruolo
               │
               ▼
        system_ruolo
               │
               ▼
       system_ruolo_modulo
               │
               ▼
      system_modulo_applicativo
```

L'utente viene autenticato tramite `system_login_utente`.

Il suo ruolo determina i permessi.

Il ruolo viene confrontato con `system_ruolo_modulo` per stabilire:

* se può visualizzare il modulo;
* se può modificarne i dati.

---

# 22. Audit

Le principali attività di audit sono gestite tramite:

### Accessi

`system_log_accessi`

Registra:

* chi ha effettuato l'accesso;
* ruolo utilizzato;
* data/ora;
* IP;
* logout.

### Operazioni

`system_log_operazioni`

Registra:

* utente;
* modulo;
* tipo di operazione;
* informazioni sull'operazione;
* data/ora.

### Storico operativo

`un_postazione_stato`

Registra le variazioni dello stato delle postazioni.

`un_storico_asset_postazione`

Registra le movimentazioni degli asset.

---

# 23. Tecnologie previste

Il database è progettato per essere utilizzato con:

* **MySQL 8.x**
* applicazione web **PHP**
* ambiente **Docker**
* frontend web per la visualizzazione delle mappe e delle postazioni.

Il database utilizza:

```text
ENGINE = InnoDB
```

e prevalentemente:

```text
utf8mb4
```

come charset.

---

# 24. Note per lo sviluppo applicativo

Durante lo sviluppo PHP si dovrà mantenere separata la logica relativa a:

1. autenticazione;
2. autorizzazione;
3. anagrafiche;
4. gestione delle postazioni;
5. gestione degli asset;
6. storico;
7. audit.

Il controllo dei permessi dovrà essere effettuato **lato server**, non esclusivamente tramite la visibilità degli elementi dell'interfaccia.

Ad esempio, nascondere un pulsante "Modifica" non è sufficiente: il PHP deve verificare comunque il permesso `modifica` prima di eseguire l'operazione.

---

# 25. Stato attuale del database

Il database comprende attualmente:

**4 tabelle principali**

* `piano`
* `zona`
* `postazione`
* `stato_postazione`

**3 tabelle di gestione/storico postazioni**

* `un_asset_postazione`
* `un_storico_asset_postazione`
* `un_postazione_stato`

**5 tabelle utenti/autorizzazioni**

* `system_utente`
* `system_login_utente`
* `system_ruolo`
* `system_ruolo_modulo`
* `system_storico_psw`

**5 tabelle di sistema/audit**

* `system_modulo_applicativo`
* `system_log_accessi`
* `system_log_operazioni`
* `system_parametri_contatori`
* `system_mittente`
* `system_token_mail`
* `system_chiave_cifratura`

Il database è predisposto per il successivo sviluppo dell'applicazione PHP e della relativa infrastruttura Docker.

