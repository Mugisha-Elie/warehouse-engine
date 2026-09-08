CREATE TYPE order_status AS ENUM ('PENDING', 'ALLOCATED', 'PACKED', 'SHIPPED', 'CANCELLED');
CREATE TYPE shipment_status AS ENUM ('DRAFT', 'ASSIGNED', 'IN_TRANSIT', 'DELIVERED');
CREATE TYPE vehicle_status AS ENUM ('AVAILABLE', 'IN_USE', 'MAINTENANCE');

CREATE TABLE IF NOT EXISTS catalog_products(
    id SERIAL PRIMARY KEY,
    sku VARCHAR(64) UNIQUE NOT NULL,
    name VARCHAR(225) NOT NULL,
    weight_kg NUMERIC(8, 2) NOT NULL CHECK (weight_kg > 0),
    volume_m3 NUMERIC(8, 3) NOT NULL CHECK (volume_m3 > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inventory_items (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES catalog_products(id) ON DELETE RESTRICT,
    warehouse_code VARCHAR(32) NOT NULL,
    bin_location VARCHAR(32) NOT NULL,
    quantity_on_hand INT NOT NULL DEFAULT 0 CHECK (quantity_on_hand >= 0),
    quantity_reserved INT NOT NULL DEFAULT 0 CHECK (quantity_reserved >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_reserved_lte_on_hand CHECK (quantity_reserved <= quantity_on_hand),
    CONSTRAINT uq_warehouse_bin_product UNIQUE (warehouse_code, bin_location, product_id)
);

CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(64) UNIQUE NOT NULL,
    status order_status NOT NULL DEFAULT 'PENDING',
    shipping_address TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_items (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES catalog_products(id) ON DELETE RESTRICT,
    quantity INT NOT NULL CHECK (quantity > 0),
    CONSTRAINT uq_order_product UNIQUE (order_id, product_id)
);

CREATE TABLE IF NOT EXISTS vehicles (
    id SERIAL PRIMARY KEY,
    plate_number VARCHAR(32) UNIQUE NOT NULL,
    model VARCHAR(128) NOT NULL,
    max_payload_kg NUMERIC(10, 2) NOT NULL CHECK (max_payload_kg > 0),
    status vehicle_status NOT NULL DEFAULT 'AVAILABLE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS shipments (
    id SERIAL PRIMARY KEY,
    shipment_number VARCHAR(64) UNIQUE NOT NULL,
    vehicle_id INT NOT NULL REFERENCES vehicles(id) ON DELETE RESTRICT,
    order_id INT UNIQUE NOT NULL REFERENCES orders(id) ON DELETE RESTRICT,
    status shipment_status NOT NULL DEFAULT 'DRAFT',
    total_weight_kg NUMERIC(10, 2) NOT NULL CHECK (total_weight_kg > 0),
    dispatched_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);