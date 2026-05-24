-- Run these in your olist database
CREATE TABLE customers (
  customer_id         TEXT PRIMARY KEY,
  customer_unique_id  TEXT,
  zip_code_prefix     TEXT,
  city                TEXT,
  state               TEXT
);

CREATE TABLE sellers (
  seller_id           TEXT PRIMARY KEY,
  zip_code_prefix     TEXT,
  city                TEXT,
  state               TEXT
);

CREATE TABLE products (
  product_id                   TEXT PRIMARY KEY,
  category_name                TEXT,
  name_length                  INT,
  description_length           INT,
  photos_qty                   INT,
  weight_g                     NUMERIC,
  length_cm                    NUMERIC,
  height_cm                    NUMERIC,
  width_cm                     NUMERIC
);

CREATE TABLE category_translation (
  category_name         TEXT PRIMARY KEY,
  category_name_english TEXT
);

CREATE TABLE orders (
  order_id                        TEXT PRIMARY KEY,
  customer_id                     TEXT REFERENCES customers(customer_id),
  status                          TEXT,
  purchase_timestamp              TIMESTAMP,
  approved_at                     TIMESTAMP,
  delivered_carrier_date          TIMESTAMP,
  delivered_customer_date         TIMESTAMP,
  estimated_delivery_date         TIMESTAMP
);

CREATE TABLE order_items (
  order_id            TEXT REFERENCES orders(order_id),
  order_item_id       INT,
  product_id          TEXT REFERENCES products(product_id),
  seller_id           TEXT REFERENCES sellers(seller_id),
  shipping_limit_date TIMESTAMP,
  price               NUMERIC(10,2),
  freight_value       NUMERIC(10,2),
  PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE order_payments (
  order_id             TEXT REFERENCES orders(order_id),
  payment_sequential   INT,
  payment_type         TEXT,
  payment_installments INT,
  payment_value        NUMERIC(10,2),
  PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE order_reviews (
  review_id           TEXT,
  order_id            TEXT REFERENCES orders(order_id),
  review_score        INT,
  comment_title       TEXT,
  comment_message     TEXT,
  creation_date       TIMESTAMP,
  answer_timestamp    TIMESTAMP,
  PRIMARY KEY (review_id, order_id)
);

CREATE TABLE geolocation (
  zip_code_prefix TEXT,
  lat             NUMERIC,
  lng             NUMERIC,
  city            TEXT,
  state           TEX
  T
);



--data download
-- Run from psql CLI or pgAdmin Query Tool
-- Adjust paths to your actual file location

\COPY customers FROM 'C:/olist/olist_customers_dataset.csv'
  DELIMITER ',' CSV HEADER;

\COPY sellers FROM 'C:/olist/olist_sellers_dataset.csv'
  DELIMITER ',' CSV HEADER;

\COPY products FROM 'C:/olist/olist_products_dataset.csv'
  DELIMITER ',' CSV HEADER;

\COPY category_translation FROM 'C:/olist/product_category_name_translation.csv'
  DELIMITER ',' CSV HEADER;

\COPY orders FROM 'C:/olist/olist_orders_dataset.csv'
  DELIMITER ',' CSV HEADER;

\COPY order_items FROM 'C:/olist/olist_order_items_dataset.csv'
  DELIMITER ',' CSV HEADER;

\COPY order_payments FROM 'C:/olist/olist_order_payments_dataset.csv'
  DELIMITER ',' CSV HEADER;

\COPY order_reviews FROM 'C:/olist/olist_order_reviews_dataset.csv'
  DELIMITER ',' CSV HEADER;

\COPY geolocation FROM 'C:/olist/olist_geolocation_dataset.csv'
  DELIMITER ',' CSV HEADER;

-- Verify row counts
SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items;