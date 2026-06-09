CREATE DATABASE PharmaExpiry;
GO

USE PharmaExpiry;
GO


CREATE TABLE Partners (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(200) NOT NULL,
    inn NVARCHAR(12),
    reg_number NVARCHAR(50),
    contacts NVARCHAR(500),
    type NVARCHAR(20) NOT NULL
);

CREATE TABLE Products (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code NVARCHAR(50) NOT NULL,
    name NVARCHAR(300) NOT NULL,
    inn NVARCHAR(200),
    form NVARCHAR(100),
    manufacturer_id INT,
    group_name NVARCHAR(100),
    shelf_days INT,
    temp_min DECIMAL(5,2),
    temp_max DECIMAL(5,2),
    light_sensitive BIT DEFAULT 0,
    prescription BIT DEFAULT 0,
    essential BIT DEFAULT 0,
    max_price DECIMAL(10,2)
);

CREATE TABLE Series (
    id INT IDENTITY(1,1) PRIMARY KEY,
    batch_num NVARCHAR(100) NOT NULL,
    product_id INT NOT NULL,
    supplier_id INT,
    prod_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    qty_received INT NOT NULL,
    qty_remaining INT NOT NULL,
    status NVARCHAR(50) NOT NULL,
    recv_date DATE
);

CREATE TABLE Locations (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(200) NOT NULL,
    type NVARCHAR(20) NOT NULL,
    address NVARCHAR(500)
);

CREATE TABLE Stock (
    id INT IDENTITY(1,1) PRIMARY KEY,
    series_id INT NOT NULL,
    location_id INT NOT NULL,
    qty INT NOT NULL,
    last_move DATE NOT NULL
);

CREATE TABLE Movements (
    id INT IDENTITY(1,1) PRIMARY KEY,
    series_id INT NOT NULL,
    type NVARCHAR(50) NOT NULL,
    from_loc_id INT,
    to_loc_id INT,
    qty INT NOT NULL,
    move_date DATETIME NOT NULL,
    doc_num NVARCHAR(100)
);

CREATE TABLE Sales (
    id INT IDENTITY(1,1) PRIMARY KEY,
    sale_num NVARCHAR(100) NOT NULL,
    pharmacy_id INT NOT NULL,
    sale_date DATETIME NOT NULL,
    cashier NVARCHAR(100)
);

CREATE TABLE SaleItems (
    id INT IDENTITY(1,1) PRIMARY KEY,
    sale_id INT NOT NULL,
    series_id INT NOT NULL,
    qty INT NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

CREATE TABLE Returns (
    id INT IDENTITY(1,1) PRIMARY KEY,
    doc_num NVARCHAR(100) NOT NULL,
    series_id INT NOT NULL,
    partner_id INT,
    ret_date DATE NOT NULL,
    qty INT NOT NULL,
    type NVARCHAR(20) NOT NULL,
    reason NVARCHAR(500)
);

CREATE TABLE Violations (
    id INT IDENTITY(1,1) PRIMARY KEY,
    location_id INT NOT NULL,
    viol_date DATETIME NOT NULL,
    temp DECIMAL(5,2),
    description NVARCHAR(500)
);

GO

-- CONSTRAINTS

-- Foreign Keys
ALTER TABLE Products ADD CONSTRAINT FK_Products_Manufacturer FOREIGN KEY (manufacturer_id) REFERENCES Partners(id);
ALTER TABLE Series ADD CONSTRAINT FK_Series_Product FOREIGN KEY (product_id) REFERENCES Products(id);
ALTER TABLE Series ADD CONSTRAINT FK_Series_Supplier FOREIGN KEY (supplier_id) REFERENCES Partners(id);
ALTER TABLE Stock ADD CONSTRAINT FK_Stock_Series FOREIGN KEY (series_id) REFERENCES Series(id) ON DELETE CASCADE;
ALTER TABLE Stock ADD CONSTRAINT FK_Stock_Location FOREIGN KEY (location_id) REFERENCES Locations(id);
ALTER TABLE Movements ADD CONSTRAINT FK_Movements_Series FOREIGN KEY (series_id) REFERENCES Series(id) ON DELETE CASCADE;
ALTER TABLE Movements ADD CONSTRAINT FK_Movements_From FOREIGN KEY (from_loc_id) REFERENCES Locations(id);
ALTER TABLE Movements ADD CONSTRAINT FK_Movements_To FOREIGN KEY (to_loc_id) REFERENCES Locations(id);
ALTER TABLE Sales ADD CONSTRAINT FK_Sales_Pharmacy FOREIGN KEY (pharmacy_id) REFERENCES Locations(id);
ALTER TABLE SaleItems ADD CONSTRAINT FK_SaleItems_Sale FOREIGN KEY (sale_id) REFERENCES Sales(id) ON DELETE CASCADE;
ALTER TABLE SaleItems ADD CONSTRAINT FK_SaleItems_Series FOREIGN KEY (series_id) REFERENCES Series(id);
ALTER TABLE Returns ADD CONSTRAINT FK_Returns_Series FOREIGN KEY (series_id) REFERENCES Series(id);
ALTER TABLE Returns ADD CONSTRAINT FK_Returns_Partner FOREIGN KEY (partner_id) REFERENCES Partners(id);
ALTER TABLE Violations ADD CONSTRAINT FK_Violations_Location FOREIGN KEY (location_id) REFERENCES Locations(id);

-- Check Constraints
ALTER TABLE Partners ADD CONSTRAINT CHK_Partner_Type CHECK (type IN ('manufacturer', 'supplier'));
ALTER TABLE Products ADD CONSTRAINT CHK_Product_Temp CHECK (temp_min <= temp_max);
ALTER TABLE Products ADD CONSTRAINT CHK_Product_Shelf CHECK (shelf_days > 0);
ALTER TABLE Products ADD CONSTRAINT CHK_Product_Price CHECK (essential = 0 OR max_price IS NOT NULL);
ALTER TABLE Series ADD CONSTRAINT CHK_Series_Dates CHECK (prod_date <= expiry_date);
ALTER TABLE Series ADD CONSTRAINT CHK_Series_Recv CHECK (recv_date IS NULL OR recv_date >= prod_date);
ALTER TABLE Series ADD CONSTRAINT CHK_Series_Qty CHECK (qty_remaining >= 0 AND qty_remaining <= qty_received);
ALTER TABLE Series ADD CONSTRAINT CHK_Series_Status CHECK (status IN ('В обороте', 'Блокировка', 'Списано'));
ALTER TABLE Locations ADD CONSTRAINT CHK_Location_Type CHECK (type IN ('warehouse', 'pharmacy', 'zone', 'cell'));
ALTER TABLE Stock ADD CONSTRAINT CHK_Stock_Qty CHECK (qty >= 0);
ALTER TABLE Movements ADD CONSTRAINT CHK_Move_Qty CHECK (qty > 0);
ALTER TABLE Movements ADD CONSTRAINT CHK_Move_Type CHECK (type IN ('приход', 'перемещение', 'возврат', 'списание', 'инвентаризация', 'продажа'));
ALTER TABLE SaleItems ADD CONSTRAINT CHK_SaleItem_Qty CHECK (qty > 0);
ALTER TABLE SaleItems ADD CONSTRAINT CHK_SaleItem_Price CHECK (price >= 0);
ALTER TABLE Returns ADD CONSTRAINT CHK_Return_Qty CHECK (qty > 0);
ALTER TABLE Returns ADD CONSTRAINT CHK_Return_Type CHECK (type IN ('возврат', 'списание'));

-- Unique Constraints
ALTER TABLE Products ADD CONSTRAINT UQ_Products_Code UNIQUE (code);
ALTER TABLE Series ADD CONSTRAINT UQ_Series_Batch UNIQUE (product_id, batch_num);
ALTER TABLE Sales ADD CONSTRAINT UQ_Sales_Num UNIQUE (sale_num);
ALTER TABLE Returns ADD CONSTRAINT UQ_Returns_Num UNIQUE (doc_num);

GO