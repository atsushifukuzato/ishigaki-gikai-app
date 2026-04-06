CREATE TYPE document_type_enum AS ENUM (
  'bill',
  'speech',
  'report',
  'consent',
  'approval'
);

ALTER TABLE bills
ADD COLUMN document_type document_type_enum NOT NULL DEFAULT 'bill';

COMMENT ON COLUMN bills.document_type IS '議会コンテンツの種別（議案、演説、報告、同意、承認）';
