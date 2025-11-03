-- Agency Table
DROP TABLE IF EXISTS Agency
CREATE TABLE Agency (
    agency_id INT PRIMARY KEY,
    agency_name NVARCHAR(255) NOT NULL,
    agency_phone NVARCHAR(15)
);

-- Ticket Table
CREATE TABLE Ticket (
    ticket_id INT PRIMARY KEY,
    agency_id INT FOREIGN KEY REFERENCES Agency(agency_id),
    cost DECIMAL(4, 2) NOT NULL
);

-- Rider Table
CREATE TABLE Rider (
    rider_id INT PRIMARY KEY,
    rider_firstname NVARCHAR(255) NOT NULL,
    rider_lastname NVARCHAR(255) NOT NULL,
);

-- Rider_Ticket Table
CREATE TABLE Rider_Ticket (
    rider_ticket_id INT PRIMARY KEY
    ticket_id INT FOREIGN KEY REFERENCES Ticket(ticket_id),
    rider_id INT FOREIGN KEY REFERENCES Rider(rider_id),
);

-- Routes Table
CREATE TABLE Routes (
    route_id INT PRIMARY KEY,
    agency_id INT FOREIGN KEY REFERENCES Agency(agency_id),
    route_short_name NVARCHAR(50),
    route_desc NVARCHAR(255),
    route_type INT
);

-- Stations Table
CREATE TABLE Stations (
    station_id INT PRIMARY KEY,
    station_name NVARCHAR(255) NOT NULL,
    station_lat FLOAT,
    station_lon FLOAT,
    wheelchair_boarding TINYINT NOT NULL
);

-- Route_Stations Table
CREATE TABLE Route_Stations (
    route_stations_id INT PRIMARY KEY,
    route_id INT FOREIGN KEY REFERENCES Routes(route_id),
    station_id INT FOREIGN KEY REFERENCES Stations(station_id)
);

-- Buses Table
CREATE TABLE Buses (
    bus_id INT PRIMARY KEY,
    bus_type NVARCHAR(50) NOT NULL,
    bus_driver_id INT FOREIGN KEY REFERENCES Bus_Driver(bus_driver_id),
);

-- Bus_Driver Table
CREATE TABLE Bus_Driver (
    bus_driver_id INT PRIMARY KEY,
    bus_driver_firstname NVARCHAR(255) NOT NULL,
    bus_driver_lastname NVARCHAR(255) NOT NULL
);

-- Trip_Details Table
CREATE TABLE Trip_Details (
    trip_detail_id INT PRIMARY KEY,
    bus_id INT FOREIGN KEY REFERENCES Buses(bus_id),
    route_id INT FOREIGN KEY REFERENCES Routes(route_id),
    rider_id INT FOREIGN KEY REFERENCES Rider(rider_id),
    trip_start_time DATETIME NOT NULL,
    trip_end_time DATETIME NOT NULL
);
