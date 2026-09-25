# gestione_postazioni

Database dell'applicazione per la gestione delle **postazioni di lavoro (PDL)**, delle relative mappe, degli asset associati, degli stati delle postazioni, degli utenti e dei permessi applicativi.

---

## 1. Tecnologie

* MySQL 8.x
* Engine: InnoDB
* Charset principale: `utf8mb4`
* Collation principale: `utf8mb4_0900_ai_ci`

Database:

```sql
gestione_postazioni
```

---

# 2. Struttura del database

Il database è suddiviso logicamente nelle seguenti aree:

### Gestione mappe e postazioni

* `piano`
* `zona`
* `postazione`
* `stato_postazione`

### Asset e storico

* `un_asset_postazione`
* `un_storico_asset_postazione`
* `un_postazione_stato`

### Utenti e autenticazione

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

### Servizi applicativi

* `system_mittente`
* `system_token_mail`
* `system_chiave_cifratura`

---

# 3. Gestione dei piani

## `piano`

Contiene l'anagrafica dei piani dell'edificio e le relative mappe.

| Campo         | Descrizione                    |
| ------------- | ------------------------------ |
| `id`          | Identificativo univoco         |
| `descrizione` | Descrizione del piano          |
| `path_mappa`  | Percorso della mappa associata |
| `attivo`      | Stato del piano                |

### Regole

* `id` è la chiave primaria.
* `path_mappa` è univoco.
* La disattivazione avviene logicamente tramite `attivo = 0`.

---

# 4. Gestione delle zone

## `zona`

Contiene le zone utilizzate per organizzare le postazioni all'interno dei piani.

| Campo         | Descrizione                        |
| ------------- | ---------------------------------- |
| `id`          | Identificativo univoco             |
| `descrizione` | Descrizione della zona             |
| `z_pos_x`     | Posizione X della zona sulla mappa |
| `z_pos_y`     | Posizione Y della zona sulla mappa |
| `attivo`      | Stato della zona                   |

Le coordinate sono espresse in percentuale e permettono di gestire la posizione indipendentemente dalla risoluzione dell'immagine della mappa.

---

# 5. Gestione delle postazioni

## `postazione`

Rappresenta una singola **postazione di lavoro (PDL)**.

| Campo               | Descrizione                     |
| ------------------- | ------------------------------- |
| `id`                | Identificativo univoco          |
| `id_piano`          | Piano di appartenenza           |
| `id_zona`           | Zona di appartenenza            |
| `codice_postazione` | Codice identificativo della PDL |
| `p_pos_x`           | Posizione X sulla mappa         |
| `p_pos_y`           | Posizione Y sulla mappa         |
| `id_stato`          | Stato corrente della postazione |
| `attivo`            | Stato della postazione          |

`codice_postazione` è univoco.

Le coordinate `p_pos_x` e `p_pos_y` sono espresse in percentuale e vengono utilizzate per il posizionamento della PDL sulla mappa.

---

# 6. Stati delle postazioni

## `stato_postazione`

Definisce gli stati disponibili per una postazione.

Configurazione iniziale:

| ID | Descrizione          | Colore  |
| -: | -------------------- | ------- |
|  1 | Libero               | `green` |
|  2 | Assegnato            | `red`   |
|  3 | Guasto/Indisponibile | `gray`  |

Il campo `colore` viene utilizzato dall'interfaccia grafica per rappresentare lo stato della postazione sulla mappa.

### Guasto/Indisponibile

Lo stato `Guasto/Indisponibile` riguarda **esclusivamente la postazione fisica**.

Non identifica un guasto della rete, di un asset o di altri servizi.

---

# 7. Asset associati alle postazioni

## `un_asset_postazione`

Contiene le associazioni degli asset alle postazioni.

| Campo               | Descrizione                  |
| ------------------- | ---------------------------- |
| `id`                | Identificativo               |
| `id_postazione`     | Postazione associata         |
| `seriale`           | Numero seriale dell'asset    |
| `id_asset`          | Identificativo dell'asset    |
| `data_associazione` | Data e ora dell'associazione |
| `id_assegnatario`   | Assegnatario dell'asset      |

Questa tabella rappresenta le associazioni correnti.

---

# 8. Storico degli asset

## `un_storico_asset_postazione`

Conserva lo storico delle associazioni degli asset alle postazioni.

| Campo                    | Descrizione                          |
| ------------------------ | ------------------------------------ |
| `id`                     | Identificativo                       |
| `id_postazione`          | Postazione                           |
| `seriale`                | Numero seriale                       |
| `id_asset`               | Identificativo asset                 |
| `data_associazione`      | Inizio dell'associazione             |
| `id_assegnatario`        | Assegnatario                         |
| `data_fine_assegnazione` | Fine dell'associazione               |
| `id_modificatore`        | Utente che ha effettuato la modifica |

### Associazione attiva

Un'associazione è considerata ancora attiva quando:

```sql
data_fine_assegnazione IS NULL
```

Quando l'associazione viene terminata vengono valorizzati:

```text
data_fine_assegnazione
id_modificatore
```

In questo modo è possibile ricostruire tutte le movimentazioni degli asset.

---

# 9. Storico degli stati delle postazioni

## `un_postazione_stato`

Registra le variazioni di stato delle postazioni.

| Campo           | Descrizione                            |
| --------------- | -------------------------------------- |
| `id`            | Identificativo                         |
| `id_postazione` | Postazione interessata                 |
| `id_stato`      | Nuovo stato                            |
| `data_stato`    | Data e ora della variazione            |
| `id_operatore`  | Utente che ha effettuato la variazione |

Esempio:

```text
PDL-001

09:00  Libero
10:15  Assegnato
14:30  Guasto/Indisponibile
16:00  Libero
```

Lo storico permette di ricostruire l'evoluzione dello stato di una PDL nel tempo.

---

# 10. Anagrafica utenti

## `system_utente`

Contiene l'anagrafica degli utenti.

| Campo     | Descrizione           |
| --------- | --------------------- |
| `id`      | Identificativo utente |
| `nome`    | Nome                  |
| `cognome` | Cognome               |
| `email`   | Email                 |
| `attivo`  | Stato dell'utente     |

L'indirizzo email è univoco.

---

# 11. Autenticazione

## `system_login_utente`

Contiene i dati necessari alla gestione dell'accesso all'applicazione.

| Campo                  | Descrizione                      |
| ---------------------- | -------------------------------- |
| `id`                   | Identificativo                   |
| `id_utente`            | Utente associato                 |
| `id_ruolo`             | Ruolo dell'utente                |
| `username`             | Nome utente                      |
| `password_hash`        | Hash della password              |
| `primo_accesso`        | Indicatore primo accesso         |
| `token`                | Token applicativo                |
| `data_cambio_password` | Data dell'ultimo cambio password |
| `flag_reset`           | Flag di reset password           |
| `data_reset`           | Data del reset                   |
| `flag_disabilitato`    | Account disabilitato             |
| `data_disabilitazione` | Data della disabilitazione       |
| `data_ultimo_accesso`  | Data dell'ultimo accesso         |
| `n_tentativi_errati`   | Numero di tentativi errati       |
| `data_spedizione`      | Data di eventuale spedizione     |
| `flg_spedizione`       | Flag di spedizione               |
| `flg_cambio_psw`       | Flag cambio password             |
| `attivo`               | Stato dell'account               |

La password viene memorizzata esclusivamente come **hash**.

Lo `username` è univoco.

---

# 12. Ruoli

## `system_ruolo`

Definisce i ruoli disponibili nell'applicazione.

Ruoli attualmente configurati:

| ID | Ruolo             | Descrizione                                                        |
| -: | ----------------- | ------------------------------------------------------------------ |
|  1 | `admin`           | Può fare tutto                                                     |
|  2 | `super_operatore` | Può accedere al pannello di configurazione e gestire le postazioni |
|  3 | `operatore`       | Può operare sulle postazioni                                       |
|  4 | `audit`           | Come il super_operatore ma in sola visualizzazione                 |

Ogni account utilizza un solo ruolo.

---

# 13. Permessi

## `system_ruolo_modulo`

Gestisce i permessi di ciascun ruolo sui moduli applicativi.

| Campo        | Descrizione                 |
| ------------ | --------------------------- |
| `id`         | Identificativo              |
| `id_ruolo`   | Ruolo                       |
| `id_modulo`  | Modulo applicativo          |
| `visualizza` | Permesso di visualizzazione |
| `modifica`   | Permesso di modifica        |

La coppia:

```text
id_ruolo + id_modulo
```

è univoca.

## Tipi di permesso

Sono previsti due soli livelli:

```text
visualizza
modifica
```

Non è previsto un permesso separato di eliminazione.

### Cancellazione logica

L'eliminazione dei dati gestibili tramite `attivo` viene effettuata logicamente:

```sql
UPDATE tabella
SET attivo = 0
WHERE id = ?;
```

Pertanto l'eliminazione logica è considerata una **modifica**.

---

# 14. Matrice dei permessi attuale

La configurazione presente nel database è:

| Ruolo             | Moduli configurazione | Gestione postazioni   | Amministrazione       | Storico               |
| ----------------- | --------------------- | --------------------- | --------------------- | --------------------- |
| `admin`           | Visualizza + Modifica | Visualizza + Modifica | Visualizza + Modifica | Visualizza + Modifica |
| `super_operatore` | Visualizza + Modifica | Visualizza + Modifica | Nessun accesso        | Nessun accesso        |
| `operatore`       | Nessun accesso        | Visualizza + Modifica | Nessun accesso        | Nessun accesso        |
| `audit`           | Visualizza            | Visualizza            | Nessun accesso        | Visualizza            |

La configurazione effettiva dei singoli moduli è determinata dai record presenti in `system_ruolo_modulo`.

---

# 15. Moduli applicativi

## `system_modulo_applicativo`

Contiene le pagine/funzionalità dell'applicazione soggette al controllo dei permessi.

| ID | Sigla                    | Pagina                                    | Descrizione                            |
| -: | ------------------------ | ----------------------------------------- | -------------------------------------- |
|  1 | `configurazione`         | `configura/index.php`                     | Dashboard dei moduli di configurazione |
|  2 | `piano`                  | `configura/piano.php`                     | Anagrafica dei piani e relative mappe  |
|  3 | `zona`                   | `configura/zona.php`                      | Anagrafica delle zone                  |
|  4 | `stato_postazione`       | `configura/stato_postazione.php`          | Anagrafica degli stati                 |
|  5 | `postazione`             | `configura/postazione.php`                | Anagrafica postazioni                  |
|  6 | `utenti`                 | `admin/utenti.php`                        | Gestione utenti e ruoli                |
|  7 | `log_accessi`            | `admin/log-accessi.php`                   | Log accessi                            |
|  8 | `storico_psw`            | `admin/storico-psw.php`                   | Storico password                       |
|  9 | `log_operazioni`         | `admin/log-operazioni.php`                | Log operazioni                         |
| 10 | `parametri_sistema`      | `admin/parametri.php`                     | Parametri sistema                      |
| 11 | `sistema_ruolo`          | `admin/sistema-ruolo.php`                 | Ruoli sistema                          |
| 12 | `postazioni`             | `postazioni/mappa_postazioni.php`         | Gestione postazioni                    |
| 13 | `storico_movimentazioni` | `postazioni/storico_mappa_postazioni.php` | Storico movimentazioni                 |

---

# 16. Parametri di sistema

## `system_parametri_contatori`

Contiene i parametri utilizzati dalla gestione della sicurezza degli account.

Configurazione iniziale:

| Parametro             | Valore | Descrizione                                  |
| --------------------- | -----: | -------------------------------------------- |
| `UguaglianzaPassword` |      5 | Numero di password precedenti da considerare |
| `TentativiErrati`     |      3 | Numero di tentativi errati consentiti        |
| `MesiInattivita`      |      6 | Periodo di inattività                        |
| `ModificaPassword`    |    180 | Periodicità del cambio password              |

---

# 17. Storico password

## `system_storico_psw`

Memorizza lo storico delle password tramite hash.

| Campo             | Descrizione                 |
| ----------------- | --------------------------- |
| `id`              | Identificativo              |
| `id_utente`       | Utente                      |
| `id_ruolo`        | Ruolo al momento del cambio |
| `psw`             | Hash della password         |
| `data_cambio_psw` | Data e ora del cambio       |

Lo storico permette di applicare il parametro `UguaglianzaPassword`.

---

# 18. Log degli accessi

## `system_log_accessi`

Registra gli accessi effettuati all'applicazione.

| Campo         | Descrizione           |
| ------------- | --------------------- |
| `id`          | Identificativo        |
| `id_utente`   | Utente                |
| `id_ruolo`    | Ruolo utilizzato      |
| `data_login`  | Data e ora del login  |
| `ip_address`  | Indirizzo IP          |
| `data_logout` | Data e ora del logout |

La memorizzazione del ruolo nel log permette di mantenere lo storico del ruolo utilizzato al momento dell'accesso.

---

# 19. Log delle operazioni

## `system_log_operazioni`

Registra le operazioni effettuate dagli utenti.

| Campo                | Descrizione                           |
| -------------------- | ------------------------------------- |
| `id`                 | Identificativo                        |
| `id_modulo`          | Modulo interessato                    |
| `id_utente`          | Utente che ha effettuato l'operazione |
| `id_tipo_operazione` | Tipo di operazione                    |
| `query`              | Informazioni relative all'operazione  |
| `data_operazione`    | Data e ora                            |

Tipi di operazione previsti:

```text
1 = INSERT
2 = UPDATE
3 = DELETE
```

Nel progetto la cancellazione dei dati anagrafici è normalmente effettuata tramite **cancellazione logica**.

---

# 20. Mittente email

## `system_mittente`

Contiene la configurazione SMTP utilizzata dall'applicazione.

| Campo           | Descrizione                |
| --------------- | -------------------------- |
| `id`            | Identificativo             |
| `email`         | Indirizzo email mittente   |
| `nome_mittente` | Nome del mittente          |
| `host`          | Server SMTP                |
| `port`          | Porta SMTP                 |
| `smtp_secure`   | Modalità di sicurezza SMTP |
| `password`      | Password SMTP              |
| `attivo`        | Stato della configurazione |

Le credenziali SMTP devono essere trattate come informazioni riservate.

---

# 21. Token email

## `system_token_mail`

Contiene le credenziali/token necessari per eventuali servizi esterni di posta.

| Campo           | Descrizione    |
| --------------- | -------------- |
| `id`            | Identificativo |
| `refresh_token` | Refresh token  |
| `client_id`     | Client ID      |
| `client_secret` | Client secret  |

Questi dati devono essere trattati come **segreti applicativi** e non devono essere inseriti in repository Git o distribuiti nei dump destinati alla pubblicazione.

---

# 22. Chiave di cifratura

## `system_chiave_cifratura`

Contiene i parametri relativi alla cifratura utilizzata dall'applicazione.

| Campo              | Descrizione                   |
| ------------------ | ----------------------------- |
| `id`               | Identificativo                |
| `chiave`           | Chiave di cifratura           |
| `metodo`           | Algoritmo/metodo di cifratura |
| `ivector`          | Initialization Vector         |
| `data_attivazione` | Data di attivazione           |
| `attivo`           | Stato della chiave            |

La chiave di cifratura deve essere considerata un **segreto applicativo**.

Per l'ambiente Docker è preferibile utilizzare Docker Secrets o variabili d'ambiente per la gestione delle chiavi.

---

# 23. Cancellazione logica

Le anagrafiche che prevedono il campo:

```text
attivo
```

utilizzano la cancellazione logica.

Valori:

```text
1 = attivo
0 = non attivo
```

Esempio:

```sql
UPDATE postazione
SET attivo = 0
WHERE id = ?;
```

Il record rimane quindi presente nel database e può continuare a essere utilizzato per lo storico e per l'audit.

---

# 24. Relazioni logiche

La struttura principale del progetto può essere rappresentata come:

```text
                         ┌──────────────┐
                         │    PIANO     │
                         └──────┬───────┘
                                │
                                │
                         ┌──────▼───────┐
                         │     ZONA     │
                         └──────┬───────┘
                                │
                         ┌──────▼────────┐
                         │  POSTAZIONE   │
                         └──┬─────┬──────┘
                            │     │
             ┌──────────────┘     └──────────────┐
             │                                   │
      ┌──────▼──────────┐              ┌─────────▼────────┐
      │ ASSET CORRENTE  │              │ STORICO STATI    │
      └─────────────────┘              └──────────────────┘
             │
      ┌──────▼──────────────┐
      │ STORICO ASSET       │
      └─────────────────────┘
```

La parte relativa agli utenti è:

```text
┌─────────────────┐
│ SYSTEM_UTENTE   │
└────────┬────────┘
         │
         ▼
┌──────────────────────┐
│ SYSTEM_LOGIN_UTENTE  │
└──────────┬───────────┘
           │
           ▼
┌─────────────────┐
│ SYSTEM_RUOLO    │
└────────┬────────┘
         │
         ▼
┌────────────────────────┐
│ SYSTEM_RUOLO_MODULO    │
└───────────┬────────────┘
            │
            ▼
┌─────────────────────────────┐
│ SYSTEM_MODULO_APPLICATIVO   │
└─────────────────────────────┘
```

---

# 25. Audit e tracciabilità

Il sistema mantiene diverse tipologie di storico.

### Storico accessi

`system_log_accessi`

Permette di sapere:

* chi ha effettuato l'accesso;
* quando;
* con quale ruolo;
* da quale IP;
* quando ha effettuato il logout.

### Storico operazioni

`system_log_operazioni`

Permette di tracciare le operazioni effettuate dall'utente sui moduli applicativi.

### Storico stati

`un_postazione_stato`

Permette di ricostruire l'evoluzione dello stato di una postazione.

### Storico asset

`un_storico_asset_postazione`

Permette di ricostruire le associazioni e movimentazioni degli asset.

---

# 26. Indici principali

Sono presenti indici per:

* chiavi primarie;
* campi univoci;
* stato di attivazione;
* ricerca per utente;
* ricerca per ruolo;
* ricerca per postazione;
* ricerca per modulo;
* ricerca cronologica degli storici.

Particolarmente importanti:

```text
un_postazione_stato
    (id_postazione, data_stato)

un_storico_asset_postazione
    (id_postazione, data_associazione)
    (id_postazione, data_fine_assegnazione)

system_ruolo_modulo
    UNIQUE (id_ruolo, id_modulo)
```

---

# 27. Convenzioni

## Flag

I campi `attivo` utilizzano:

```text
1 = attivo
0 = non attivo
```

## Date

I campi temporali utilizzano `DATETIME`.

## Identificativi

Gli identificativi principali sono `INT` con `AUTO_INCREMENT`.

## Storici

Gli storici non devono essere modificati per rappresentare una nuova situazione: le nuove variazioni devono essere registrate come nuovi eventi o come chiusura dell'evento precedente, secondo la logica specifica della tabella.

---

# 28. Sicurezza

Le password degli utenti devono essere memorizzate esclusivamente tramite hash sicuro.

Non devono essere memorizzate password in chiaro.

Particolare attenzione deve essere posta a:

* `system_mittente.password`
* `system_token_mail.refresh_token`
* `system_token_mail.client_secret`
* `system_chiave_cifratura.chiave`

Questi valori rappresentano credenziali o segreti applicativi e non devono essere esposti nel codice sorgente, nei repository Git o nei dump SQL condivisi.

---

# 29. Prossimo livello applicativo

Il database costituisce il livello dati dell'applicazione.

L'applicazione PHP dovrà occuparsi principalmente di:

1. autenticazione dell'utente;
2. gestione della sessione;
3. verifica dei permessi;
4. gestione delle anagrafiche;
5. visualizzazione delle mappe;
6. gestione delle postazioni;
7. associazione degli asset;
8. gestione degli stati;
9. gestione degli storici;
10. registrazione degli accessi;
11. registrazione delle operazioni;
12. gestione della configurazione.

Il controllo dei permessi deve essere effettuato **lato server**. La semplice rimozione/nascondimento di un pulsante nell'interfaccia non costituisce un controllo di sicurezza sufficiente.

---

# 30. Stato dello schema

Lo schema attuale comprende **19 tabelle**:

### Postazioni

1. `piano`
2. `zona`
3. `postazione`
4. `stato_postazione`
5. `un_asset_postazione`
6. `un_storico_asset_postazione`
7. `un_postazione_stato`

### Utenti e autorizzazioni

8. `system_utente`
9. `system_login_utente`
10. `system_ruolo`
11. `system_ruolo_modulo`
12. `system_storico_psw`

### Sistema e audit

13. `system_modulo_applicativo`
14. `system_log_accessi`
15. `system_log_operazioni`
16. `system_parametri_contatori`

### Servizi e sicurezza

17. `system_mittente`
18. `system_token_mail`
19. `system_chiave_cifratura`

Lo schema è predisposto per essere utilizzato come base dati dell'applicazione PHP all'interno dell'ambiente Docker.