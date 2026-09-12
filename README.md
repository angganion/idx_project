# Final Task Data Engineer - ID/X Partners

Pembangunan Data Warehouse untuk salah satu klien ID/X Partners yang bergerak di industri perbankan. Data sumber tersebar di file Excel, file CSV, dan database SQL Server, sehingga pelaporan dan analisis menjadi lambat. Project ini menyatukan seluruh sumber tersebut ke dalam satu Data Warehouse `DWH` melalui proses ETL.

## Sumber Data

| Sumber | Bentuk | Keterangan |
| --- | --- | --- |
| `transaction_excel.xlsx` | Excel | 7 transaksi |
| `transaction_csv.csv` | CSV | 12 transaksi |
| `transaction_db` | SQL Server | 10 transaksi |
| `account` | SQL Server | 21 rekening |
| `customer` | SQL Server | 20 nasabah |
| `branch` | SQL Server | 5 kantor cabang |
| `city` | SQL Server | Data kelurahan |
| `state` | SQL Server | Data kota |

File `sample.bak` adalah backup database sumber yang berisi tabel `transaction_db`, `account`, `customer`, `branch`, `city`, dan `state`.

## Struktur Folder

```
.
├── scripts/                        Script SQL
│   ├── 00_restore_bak.sql          Restore database sample
│   ├── 01_create_dwh.sql           Membuat database DWH beserta tabel
│   └── 02_stored_procedures.sql    Membuat stored procedure
├── talend/                         Job ETL Talend
│   ├── LoadDimCustomer_0.1.item
│   ├── LoadDimBranch_0.1.item
│   ├── LoadDimAccount_0.1.item
│   └── LoadFactTransaction_0.1.item
├── transaction_csv.csv             Sumber transaksi (CSV)
├── transaction_excel.xlsx          Sumber transaksi (Excel)
└── sample.bak                      Backup database sumber
```

## Skema Data Warehouse

Tabel dimension:

- `DimCustomer` (CustomerID, CustomerName, Address, CityName, StateName, Age, Gender, Email)
- `DimBranch` (BranchID, BranchName, BranchLocation)
- `DimAccount` (AccountID, CustomerID, AccountType, Balance, DateOpened, Status)

Tabel fact:

- `FactTransaction` (TransactionID, AccountID, TransactionDate, Amount, TransactionType, BranchID)

Relasi: `DimAccount` mengacu ke `DimCustomer`, sedangkan `FactTransaction` mengacu ke `DimAccount` dan `DimBranch`.

## Alur ETL

```
customer + city + state ─→ tMap ─→ DimCustomer
branch ─────────────────→ DimBranch
account ────────────────→ DimAccount

transaction_excel ─┐
transaction_csv ───┼─→ tMap → tUnite → tUniq → tMap + DimAccount → FactTransaction
transaction_db ────┘
```

Aturan transformasi:

- Seluruh nama kolom memakai kaidah PascalCase.
- Khusus `DimCustomer`, kolom CustomerName, Address, CityName, StateName, dan Gender diubah menjadi huruf kapital.
- Kolom CustomerID, Age, dan Email tidak diubah.
- `tUniq` memakai TransactionID sebagai key agar tidak ada baris duplikat di `FactTransaction`.
- Sebelum dimuat, transaksi disaring dengan inner join ke `DimAccount` supaya hanya transaksi dengan rekening yang valid yang masuk.

## Cara Menjalankan

1. Restore database sumber dengan `scripts/00_restore_bak.sql`.
2. Buat database dan tabel DWH dengan `scripts/01_create_dwh.sql`.
3. Jalankan job Talend secara berurutan: `LoadDimCustomer`, `LoadDimBranch`, `LoadDimAccount`, lalu `LoadFactTransaction`.
4. Buat stored procedure dengan `scripts/02_stored_procedures.sql`.

## Stored Procedure

`DailyTransaction` menampilkan jumlah transaksi dan total nominalnya per hari dalam rentang tanggal tertentu.

```sql
EXEC dbo.DailyTransaction @start_date = '2022-01-01', @end_date = '2022-03-31';
```

`BalancePerCustomer` menampilkan saldo awal dan saldo akhir tiap rekening nasabah. Transaksi bertipe Deposit menambah saldo, sedangkan tipe lainnya mengurangi saldo. Hanya rekening berstatus active yang ditampilkan.

```sql
EXEC dbo.BalancePerCustomer @name = 'Shelly';
```

## Hasil

| Tabel | Jumlah Baris |
| --- | --- |
| DimCustomer | 20 |
| DimBranch | 5 |
| DimAccount | 21 |
| FactTransaction | 22 |

Contoh hasil `BalancePerCustomer` untuk nasabah Shelly:

| CustomerName | AccountType | Balance | CurrentBalance |
| --- | --- | --- | --- |
| SHELLY JUWITA | checking | 25000000 | 14000000 |
| SHELLY JUWITA | saving | 1500000 | 1600000 |
