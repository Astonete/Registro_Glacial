-- Crea todas las tablas en orden

CREATE TABLE IF NOT EXISTS "customers" (
    "customer_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "full_name" TEXT NOT NULL,
    "email" TEXT NOT NULL UNIQUE CHECK(email LIKE '%_@__%.__%'),
    "phone" TEXT,
    "city" TEXT NOT NULL,
    "segment" TEXT CHECK(segment IN ('retail','wholesale','online_only','vip')),
    "created_at" TEXT NOT NULL,
    "is_active" INTEGER NOT NULL CHECK("is_active" IN (0,1)),
    "deleted_at" TEXT
);

CREATE TABLE IF NOT EXISTS "products" (
    "product_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "sku" TEXT NOT NULL UNIQUE,
    "product_name" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "brand" TEXT NOT NULL,
    "unit_price" REAL NOT NULL CHECK("unit_price" >= 0),
    "unit_cost" REAL NOT NULL CHECK("unit_cost" >= 0),
    "created_at" TEXT NOT NULL,
    "is_active" INTEGER NOT NULL CHECK("is_active" IN (0,1)),
    "deleted_at" TEXT,
    CHECK(unit_price >= unit_cost)
);

CREATE TABLE IF NOT EXISTS "orders" (
    "order_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "customer_id" INTEGER NOT NULL,
    "order_datetime" TEXT NOT NULL,
    "channel" TEXT CHECK(channel IN ('web','mobile','phone','store')),
    "currency" TEXT CHECK(currency IN ('PYG','USD')),
    "current_status" TEXT CHECK ("current_status" IN ('created','packed','paid','shipped','delivered','cancelled','refunded')),
    "is_active" INTEGER NOT NULL CHECK("is_active" IN (0,1)),
    "deleted_at" TEXT,
    "order_total" REAL CHECK ("order_total" >= 0),
    FOREIGN KEY ("customer_id") REFERENCES "customers"("customer_id")
);

CREATE TABLE IF NOT EXISTS "order_items" (
    "order_item_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "order_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL CHECK("quantity" > 0),
    "unit_price" REAL NOT NULL CHECK("unit_price" >= 0),
    "discount_rate" REAL NOT NULL CHECK("discount_rate" >= 0 AND "discount_rate" <= 1),
    "line_total" REAL NOT NULL CHECK("line_total" >= 0),
    FOREIGN KEY ("order_id") REFERENCES "orders"("order_id"),
    FOREIGN KEY ("product_id") REFERENCES "products"("product_id")
);

CREATE TABLE IF NOT EXISTS "payments" (
    "payment_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "order_id" INTEGER NOT NULL,
    "payment_datetime" TEXT NOT NULL,
    "method" TEXT NOT NULL CHECK(method IN ('card','transfer','cash','wallet')),
    "amount" REAL NOT NULL CHECK("amount" >= 0),
    "payment_status" TEXT NOT NULL CHECK(payment_status IN ('approved','pending','failed','refunded','rejected')),
    "currency" TEXT NOT NULL CHECK(currency IN ('PYG','USD')),
    FOREIGN KEY ("order_id") REFERENCES "orders"("order_id")
);

CREATE TABLE IF NOT EXISTS "order_status_history" (
    "status_history_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "order_id" INTEGER NOT NULL,
    "status" TEXT NOT NULL CHECK(status IN ('shipped','packed','delivered','created','paid','refunded','cancelled')),
    "changed_at" TEXT NOT NULL,
    "changed_by" TEXT NOT NULL CHECK(changed_by IN ('system','warehouse','user','ops','payment_gateway')),
    "reason" TEXT CHECK(reason IN ('service_issue', 'return', 'customer_request', 'payment_failed','fraud_check', 'chargeback', 'out_of_stock')),
    FOREIGN KEY ("order_id") REFERENCES "orders"("order_id")
);

CREATE TABLE IF NOT EXISTS "order_audit" (
    "audit_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "order_id" INTEGER NOT NULL,
    "field_name" TEXT NOT NULL CHECK(field_name IN ('current_status','shipping_address','order_total','notes','customer_phone')),
    "old_value" TEXT NOT NULL,
    "new_value" TEXT NOT NULL,
    "changed_at" TEXT NOT NULL,
    "changed_by" TEXT NOT NULL CHECK(changed_by IN ('system','support','ops')),
    FOREIGN KEY ("order_id") REFERENCES "orders"("order_id")
);

-- Índices para FK y JOINs
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_payments_order_id ON payments(order_id);
CREATE INDEX IF NOT EXISTS idx_order_status_history_order_id ON order_status_history(order_id);
CREATE INDEX IF NOT EXISTS idx_order_audit_order_id ON order_audit(order_id);

-- Índices para filtros frecuentes
CREATE INDEX IF NOT EXISTS idx_orders_current_status ON orders(current_status);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_orders_datetime ON orders(order_datetime);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(payment_status);
