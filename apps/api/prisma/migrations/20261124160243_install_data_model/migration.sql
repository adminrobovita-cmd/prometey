-- CreateEnum
CREATE TYPE "UserStatus" AS ENUM ('INVITED', 'ACTIVE', 'BLOCKED');

-- CreateEnum
CREATE TYPE "MembershipRole" AS ENUM ('OWNER', 'ADMIN', 'OPERATOR', 'VIEWER');

-- CreateEnum
CREATE TYPE "AccessScope" AS ENUM ('ORGANIZATION', 'SELECTED_ZONES');

-- CreateEnum
CREATE TYPE "ZoneType" AS ENUM ('BOILER_ROOM', 'WORKSHOP', 'BUILDING', 'OTHER');

-- CreateEnum
CREATE TYPE "DeviceType" AS ENUM ('BOILER_CONTROLLER', 'TEMPERATURE_CONTROLLER', 'RFID_READER', 'GATEWAY', 'OTHER');

-- CreateEnum
CREATE TYPE "DeviceStatus" AS ENUM ('ONLINE', 'OFFLINE', 'UNKNOWN');

-- CreateEnum
CREATE TYPE "ChannelDataType" AS ENUM ('NUMBER', 'BOOLEAN');

-- CreateEnum
CREATE TYPE "MeasurementKind" AS ENUM ('TEMPERATURE', 'PRESSURE', 'PUMP_STATE', 'CONTACT_STATE', 'HUMIDITY', 'OTHER');

-- CreateEnum
CREATE TYPE "RecordingMode" AS ENUM ('INTERVAL', 'ON_CHANGE', 'INTERVAL_AND_CHANGE');

-- CreateEnum
CREATE TYPE "TelemetryQuality" AS ENUM ('GOOD', 'UNCERTAIN', 'BAD');

-- CreateEnum
CREATE TYPE "IntegrationProtocol" AS ENUM ('HTTP', 'MQTT', 'HOME_ASSISTANT', 'MODBUS_TCP', 'MODBUS_RTU', 'OPC_UA', 'MANUAL');

-- CreateEnum
CREATE TYPE "IntegrationStatus" AS ENUM ('ENABLED', 'DISABLED', 'ERROR');

-- CreateEnum
CREATE TYPE "EventType" AS ENUM ('THRESHOLD', 'DEVICE_OFFLINE', 'SENSOR_ERROR', 'INSPECTION_OVERDUE', 'SYSTEM', 'MANUAL');

-- CreateEnum
CREATE TYPE "EventSeverity" AS ENUM ('INFO', 'WARNING', 'CRITICAL');

-- CreateEnum
CREATE TYPE "EventStatus" AS ENUM ('ACTIVE', 'ACKNOWLEDGED', 'RESOLVED');

-- CreateEnum
CREATE TYPE "InspectionMethod" AS ENUM ('RFID', 'MANUAL');

-- CreateEnum
CREATE TYPE "InspectionStatus" AS ENUM ('COMPLETED', 'REJECTED');

-- CreateEnum
CREATE TYPE "NotificationChannel" AS ENUM ('TELEGRAM', 'WEB');

-- CreateEnum
CREATE TYPE "DeliveryStatus" AS ENUM ('PENDING', 'SENT', 'FAILED', 'SKIPPED');

-- CreateEnum
CREATE TYPE "AuditAction" AS ENUM ('CREATE', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT', 'ACCESS_DENIED', 'ACKNOWLEDGE_EVENT', 'RESOLVE_EVENT', 'OTHER');

-- CreateTable
CREATE TABLE "organizations" (
    "id" UUID NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "slug" VARCHAR(100) NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "telemetryRetentionMonths" INTEGER NOT NULL DEFAULT 6,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "organizations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sites" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "code" VARCHAR(80),
    "address" VARCHAR(500),
    "timeZone" VARCHAR(80) NOT NULL DEFAULT 'Europe/Minsk',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "sites_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "zones" (
    "id" UUID NOT NULL,
    "siteId" UUID NOT NULL,
    "parentId" UUID,
    "name" VARCHAR(200) NOT NULL,
    "code" VARCHAR(80),
    "type" "ZoneType" NOT NULL DEFAULT 'OTHER',
    "notes" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "zones_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "heating_circuits" (
    "id" UUID NOT NULL,
    "zoneId" UUID NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "code" VARCHAR(80),
    "description" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "heating_circuits_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "email" VARCHAR(320) NOT NULL,
    "passwordHash" VARCHAR(255) NOT NULL,
    "displayName" VARCHAR(200) NOT NULL,
    "phone" VARCHAR(40),
    "status" "UserStatus" NOT NULL DEFAULT 'INVITED',
    "isSystemAdmin" BOOLEAN NOT NULL DEFAULT false,
    "lastLoginAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "organization_memberships" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "role" "MembershipRole" NOT NULL DEFAULT 'OPERATOR',
    "scope" "AccessScope" NOT NULL DEFAULT 'SELECTED_ZONES',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "organization_memberships_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_zone_access" (
    "id" UUID NOT NULL,
    "membershipId" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "zoneId" UUID NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_zone_access_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "integration_connections" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "siteId" UUID,
    "name" VARCHAR(200) NOT NULL,
    "protocol" "IntegrationProtocol" NOT NULL,
    "status" "IntegrationStatus" NOT NULL DEFAULT 'ENABLED',
    "settings" JSONB,
    "lastError" TEXT,
    "lastConnectedAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "integration_connections_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "devices" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "siteId" UUID NOT NULL,
    "zoneId" UUID NOT NULL,
    "heatingCircuitId" UUID,
    "integrationConnectionId" UUID,
    "name" VARCHAR(200) NOT NULL,
    "code" VARCHAR(100) NOT NULL,
    "type" "DeviceType" NOT NULL DEFAULT 'OTHER',
    "status" "DeviceStatus" NOT NULL DEFAULT 'UNKNOWN',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "lastSeenAt" TIMESTAMPTZ(3),
    "offlineAfterSeconds" INTEGER NOT NULL DEFAULT 120,
    "firmwareVersion" VARCHAR(100),
    "metadata" JSONB,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "devices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "device_credentials" (
    "id" UUID NOT NULL,
    "deviceId" UUID NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "secretHash" VARCHAR(255) NOT NULL,
    "expiresAt" TIMESTAMPTZ(3),
    "revokedAt" TIMESTAMPTZ(3),
    "lastUsedAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "device_credentials_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "device_status_history" (
    "id" UUID NOT NULL,
    "deviceId" UUID NOT NULL,
    "status" "DeviceStatus" NOT NULL,
    "changedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reason" VARCHAR(500),

    CONSTRAINT "device_status_history_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "device_channels" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "deviceId" UUID NOT NULL,
    "code" VARCHAR(100) NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "measurementKind" "MeasurementKind" NOT NULL DEFAULT 'OTHER',
    "dataType" "ChannelDataType" NOT NULL DEFAULT 'NUMBER',
    "unit" VARCHAR(30),
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "trueMeaning" VARCHAR(100),
    "falseMeaning" VARCHAR(100),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "device_channels_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "channel_recording_policies" (
    "id" UUID NOT NULL,
    "channelId" UUID NOT NULL,
    "mode" "RecordingMode" NOT NULL DEFAULT 'INTERVAL_AND_CHANGE',
    "intervalSeconds" INTEGER,
    "changeThreshold" DECIMAL(14,4),
    "recordFirstValue" BOOLEAN NOT NULL DEFAULT true,
    "enabled" BOOLEAN NOT NULL DEFAULT true,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "channel_recording_policies_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "telemetry_records" (
    "id" BIGSERIAL NOT NULL,
    "channelId" UUID NOT NULL,
    "recordedAt" TIMESTAMPTZ(3) NOT NULL,
    "receivedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "numberValue" DECIMAL(14,4),
    "booleanValue" BOOLEAN,
    "quality" "TelemetryQuality" NOT NULL DEFAULT 'GOOD',
    "sourceMessageId" VARCHAR(160),
    "rawPayload" JSONB,

    CONSTRAINT "telemetry_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "channel_thresholds" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "channelId" UUID NOT NULL,
    "warningLow" DECIMAL(14,4),
    "warningHigh" DECIMAL(14,4),
    "criticalLow" DECIMAL(14,4),
    "criticalHigh" DECIMAL(14,4),
    "hysteresis" DECIMAL(14,4) NOT NULL DEFAULT 0,
    "enabled" BOOLEAN NOT NULL DEFAULT true,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "channel_thresholds_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "monitoring_events" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "zoneId" UUID,
    "channelId" UUID,
    "type" "EventType" NOT NULL,
    "severity" "EventSeverity" NOT NULL,
    "status" "EventStatus" NOT NULL DEFAULT 'ACTIVE',
    "title" VARCHAR(250) NOT NULL,
    "description" TEXT,
    "valueAtTrigger" DECIMAL(14,4),
    "startedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "acknowledgedAt" TIMESTAMPTZ(3),
    "acknowledgedByUserId" UUID,
    "resolvedAt" TIMESTAMPTZ(3),
    "deduplicationKey" VARCHAR(200),
    "metadata" JSONB,

    CONSTRAINT "monitoring_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "event_history" (
    "id" UUID NOT NULL,
    "eventId" UUID NOT NULL,
    "fromStatus" "EventStatus",
    "toStatus" "EventStatus" NOT NULL,
    "comment" TEXT,
    "changedById" UUID,
    "changedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "event_history_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "rfid_readers" (
    "id" UUID NOT NULL,
    "deviceId" UUID NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "rfid_readers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "rfid_cards" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "cardUid" VARCHAR(100) NOT NULL,
    "label" VARCHAR(200),
    "userId" UUID,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "revokedAt" TIMESTAMPTZ(3),

    CONSTRAINT "rfid_cards_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "inspection_rules" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "zoneId" UUID NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "intervalMinutes" INTEGER NOT NULL,
    "graceMinutes" INTEGER NOT NULL DEFAULT 0,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "inspection_rules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "inspections" (
    "id" UUID NOT NULL,
    "ruleId" UUID NOT NULL,
    "zoneId" UUID NOT NULL,
    "userId" UUID,
    "readerId" UUID,
    "method" "InspectionMethod" NOT NULL,
    "status" "InspectionStatus" NOT NULL DEFAULT 'COMPLETED',
    "cardUid" VARCHAR(100),
    "inspectedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "comment" TEXT,
    "sourceEventId" VARCHAR(160),

    CONSTRAINT "inspections_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "telegram_accounts" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "chatId" VARCHAR(40) NOT NULL,
    "verifiedAt" TIMESTAMPTZ(3),
    "isEnabled" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "telegram_accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notification_deliveries" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "eventId" UUID,
    "userId" UUID NOT NULL,
    "channel" "NotificationChannel" NOT NULL,
    "status" "DeliveryStatus" NOT NULL DEFAULT 'PENDING',
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "scheduledAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "sentAt" TIMESTAMPTZ(3),
    "lastError" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notification_deliveries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" BIGSERIAL NOT NULL,
    "organizationId" UUID,
    "userId" UUID,
    "action" "AuditAction" NOT NULL,
    "entityType" VARCHAR(100) NOT NULL,
    "entityId" VARCHAR(100),
    "ipAddress" VARCHAR(45),
    "userAgent" VARCHAR(500),
    "details" JSONB,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "organizations_slug_key" ON "organizations"("slug");

-- CreateIndex
CREATE INDEX "organizations_isActive_name_idx" ON "organizations"("isActive", "name");

-- CreateIndex
CREATE INDEX "sites_organizationId_isActive_idx" ON "sites"("organizationId", "isActive");

-- CreateIndex
CREATE UNIQUE INDEX "sites_organizationId_code_key" ON "sites"("organizationId", "code");

-- CreateIndex
CREATE INDEX "zones_siteId_isActive_idx" ON "zones"("siteId", "isActive");

-- CreateIndex
CREATE INDEX "zones_parentId_idx" ON "zones"("parentId");

-- CreateIndex
CREATE UNIQUE INDEX "zones_siteId_code_key" ON "zones"("siteId", "code");

-- CreateIndex
CREATE INDEX "heating_circuits_zoneId_isActive_idx" ON "heating_circuits"("zoneId", "isActive");

-- CreateIndex
CREATE UNIQUE INDEX "heating_circuits_zoneId_code_key" ON "heating_circuits"("zoneId", "code");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "users_status_displayName_idx" ON "users"("status", "displayName");

-- CreateIndex
CREATE INDEX "organization_memberships_userId_isActive_idx" ON "organization_memberships"("userId", "isActive");

-- CreateIndex
CREATE INDEX "organization_memberships_organizationId_role_isActive_idx" ON "organization_memberships"("organizationId", "role", "isActive");

-- CreateIndex
CREATE UNIQUE INDEX "organization_memberships_organizationId_userId_key" ON "organization_memberships"("organizationId", "userId");

-- CreateIndex
CREATE INDEX "user_zone_access_userId_zoneId_idx" ON "user_zone_access"("userId", "zoneId");

-- CreateIndex
CREATE INDEX "user_zone_access_zoneId_idx" ON "user_zone_access"("zoneId");

-- CreateIndex
CREATE UNIQUE INDEX "user_zone_access_membershipId_zoneId_key" ON "user_zone_access"("membershipId", "zoneId");

-- CreateIndex
CREATE INDEX "integration_connections_organizationId_protocol_status_idx" ON "integration_connections"("organizationId", "protocol", "status");

-- CreateIndex
CREATE INDEX "integration_connections_siteId_idx" ON "integration_connections"("siteId");

-- CreateIndex
CREATE INDEX "devices_organizationId_status_isActive_idx" ON "devices"("organizationId", "status", "isActive");

-- CreateIndex
CREATE INDEX "devices_siteId_zoneId_idx" ON "devices"("siteId", "zoneId");

-- CreateIndex
CREATE INDEX "devices_zoneId_isActive_idx" ON "devices"("zoneId", "isActive");

-- CreateIndex
CREATE INDEX "devices_lastSeenAt_idx" ON "devices"("lastSeenAt");

-- CreateIndex
CREATE UNIQUE INDEX "devices_organizationId_code_key" ON "devices"("organizationId", "code");

-- CreateIndex
CREATE INDEX "device_credentials_deviceId_revokedAt_idx" ON "device_credentials"("deviceId", "revokedAt");

-- CreateIndex
CREATE INDEX "device_status_history_deviceId_changedAt_idx" ON "device_status_history"("deviceId", "changedAt" DESC);

-- CreateIndex
CREATE INDEX "device_channels_organizationId_measurementKind_isActive_idx" ON "device_channels"("organizationId", "measurementKind", "isActive");

-- CreateIndex
CREATE INDEX "device_channels_deviceId_isActive_idx" ON "device_channels"("deviceId", "isActive");

-- CreateIndex
CREATE UNIQUE INDEX "device_channels_deviceId_code_key" ON "device_channels"("deviceId", "code");

-- CreateIndex
CREATE UNIQUE INDEX "channel_recording_policies_channelId_key" ON "channel_recording_policies"("channelId");

-- CreateIndex
CREATE INDEX "telemetry_records_channelId_recordedAt_idx" ON "telemetry_records"("channelId", "recordedAt" DESC);

-- CreateIndex
CREATE INDEX "telemetry_records_receivedAt_idx" ON "telemetry_records"("receivedAt");

-- CreateIndex
CREATE UNIQUE INDEX "telemetry_records_channelId_sourceMessageId_key" ON "telemetry_records"("channelId", "sourceMessageId");

-- CreateIndex
CREATE UNIQUE INDEX "channel_thresholds_channelId_key" ON "channel_thresholds"("channelId");

-- CreateIndex
CREATE INDEX "channel_thresholds_organizationId_enabled_idx" ON "channel_thresholds"("organizationId", "enabled");

-- CreateIndex
CREATE INDEX "monitoring_events_organizationId_status_startedAt_idx" ON "monitoring_events"("organizationId", "status", "startedAt" DESC);

-- CreateIndex
CREATE INDEX "monitoring_events_zoneId_status_startedAt_idx" ON "monitoring_events"("zoneId", "status", "startedAt" DESC);

-- CreateIndex
CREATE INDEX "monitoring_events_channelId_startedAt_idx" ON "monitoring_events"("channelId", "startedAt" DESC);

-- CreateIndex
CREATE INDEX "monitoring_events_type_status_idx" ON "monitoring_events"("type", "status");

-- CreateIndex
CREATE INDEX "monitoring_events_deduplicationKey_idx" ON "monitoring_events"("deduplicationKey");

-- CreateIndex
CREATE INDEX "event_history_eventId_changedAt_idx" ON "event_history"("eventId", "changedAt");

-- CreateIndex
CREATE UNIQUE INDEX "rfid_readers_deviceId_key" ON "rfid_readers"("deviceId");

-- CreateIndex
CREATE INDEX "rfid_cards_organizationId_isActive_idx" ON "rfid_cards"("organizationId", "isActive");

-- CreateIndex
CREATE UNIQUE INDEX "rfid_cards_organizationId_cardUid_key" ON "rfid_cards"("organizationId", "cardUid");

-- CreateIndex
CREATE INDEX "inspection_rules_organizationId_zoneId_isActive_idx" ON "inspection_rules"("organizationId", "zoneId", "isActive");

-- CreateIndex
CREATE INDEX "inspections_ruleId_inspectedAt_idx" ON "inspections"("ruleId", "inspectedAt" DESC);

-- CreateIndex
CREATE INDEX "inspections_zoneId_inspectedAt_idx" ON "inspections"("zoneId", "inspectedAt" DESC);

-- CreateIndex
CREATE INDEX "inspections_userId_inspectedAt_idx" ON "inspections"("userId", "inspectedAt" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "inspections_readerId_sourceEventId_key" ON "inspections"("readerId", "sourceEventId");

-- CreateIndex
CREATE UNIQUE INDEX "telegram_accounts_userId_key" ON "telegram_accounts"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "telegram_accounts_chatId_key" ON "telegram_accounts"("chatId");

-- CreateIndex
CREATE INDEX "notification_deliveries_status_scheduledAt_idx" ON "notification_deliveries"("status", "scheduledAt");

-- CreateIndex
CREATE INDEX "notification_deliveries_organizationId_createdAt_idx" ON "notification_deliveries"("organizationId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "notification_deliveries_userId_createdAt_idx" ON "notification_deliveries"("userId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "notification_deliveries_eventId_idx" ON "notification_deliveries"("eventId");

-- CreateIndex
CREATE INDEX "audit_logs_organizationId_createdAt_idx" ON "audit_logs"("organizationId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "audit_logs_userId_createdAt_idx" ON "audit_logs"("userId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "audit_logs_entityType_entityId_idx" ON "audit_logs"("entityType", "entityId");

-- AddForeignKey
ALTER TABLE "sites" ADD CONSTRAINT "sites_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "zones" ADD CONSTRAINT "zones_siteId_fkey" FOREIGN KEY ("siteId") REFERENCES "sites"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "zones" ADD CONSTRAINT "zones_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES "zones"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "heating_circuits" ADD CONSTRAINT "heating_circuits_zoneId_fkey" FOREIGN KEY ("zoneId") REFERENCES "zones"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "organization_memberships" ADD CONSTRAINT "organization_memberships_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "organization_memberships" ADD CONSTRAINT "organization_memberships_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_zone_access" ADD CONSTRAINT "user_zone_access_membershipId_fkey" FOREIGN KEY ("membershipId") REFERENCES "organization_memberships"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_zone_access" ADD CONSTRAINT "user_zone_access_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_zone_access" ADD CONSTRAINT "user_zone_access_zoneId_fkey" FOREIGN KEY ("zoneId") REFERENCES "zones"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "integration_connections" ADD CONSTRAINT "integration_connections_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "integration_connections" ADD CONSTRAINT "integration_connections_siteId_fkey" FOREIGN KEY ("siteId") REFERENCES "sites"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "devices" ADD CONSTRAINT "devices_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "devices" ADD CONSTRAINT "devices_siteId_fkey" FOREIGN KEY ("siteId") REFERENCES "sites"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "devices" ADD CONSTRAINT "devices_zoneId_fkey" FOREIGN KEY ("zoneId") REFERENCES "zones"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "devices" ADD CONSTRAINT "devices_heatingCircuitId_fkey" FOREIGN KEY ("heatingCircuitId") REFERENCES "heating_circuits"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "devices" ADD CONSTRAINT "devices_integrationConnectionId_fkey" FOREIGN KEY ("integrationConnectionId") REFERENCES "integration_connections"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "device_credentials" ADD CONSTRAINT "device_credentials_deviceId_fkey" FOREIGN KEY ("deviceId") REFERENCES "devices"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "device_status_history" ADD CONSTRAINT "device_status_history_deviceId_fkey" FOREIGN KEY ("deviceId") REFERENCES "devices"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "device_channels" ADD CONSTRAINT "device_channels_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "device_channels" ADD CONSTRAINT "device_channels_deviceId_fkey" FOREIGN KEY ("deviceId") REFERENCES "devices"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "channel_recording_policies" ADD CONSTRAINT "channel_recording_policies_channelId_fkey" FOREIGN KEY ("channelId") REFERENCES "device_channels"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "telemetry_records" ADD CONSTRAINT "telemetry_records_channelId_fkey" FOREIGN KEY ("channelId") REFERENCES "device_channels"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "channel_thresholds" ADD CONSTRAINT "channel_thresholds_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "channel_thresholds" ADD CONSTRAINT "channel_thresholds_channelId_fkey" FOREIGN KEY ("channelId") REFERENCES "device_channels"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "monitoring_events" ADD CONSTRAINT "monitoring_events_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "monitoring_events" ADD CONSTRAINT "monitoring_events_zoneId_fkey" FOREIGN KEY ("zoneId") REFERENCES "zones"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "monitoring_events" ADD CONSTRAINT "monitoring_events_channelId_fkey" FOREIGN KEY ("channelId") REFERENCES "device_channels"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "monitoring_events" ADD CONSTRAINT "monitoring_events_acknowledgedByUserId_fkey" FOREIGN KEY ("acknowledgedByUserId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "event_history" ADD CONSTRAINT "event_history_eventId_fkey" FOREIGN KEY ("eventId") REFERENCES "monitoring_events"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rfid_readers" ADD CONSTRAINT "rfid_readers_deviceId_fkey" FOREIGN KEY ("deviceId") REFERENCES "devices"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rfid_cards" ADD CONSTRAINT "rfid_cards_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rfid_cards" ADD CONSTRAINT "rfid_cards_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inspection_rules" ADD CONSTRAINT "inspection_rules_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inspection_rules" ADD CONSTRAINT "inspection_rules_zoneId_fkey" FOREIGN KEY ("zoneId") REFERENCES "zones"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inspections" ADD CONSTRAINT "inspections_ruleId_fkey" FOREIGN KEY ("ruleId") REFERENCES "inspection_rules"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inspections" ADD CONSTRAINT "inspections_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inspections" ADD CONSTRAINT "inspections_readerId_fkey" FOREIGN KEY ("readerId") REFERENCES "rfid_readers"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "telegram_accounts" ADD CONSTRAINT "telegram_accounts_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notification_deliveries" ADD CONSTRAINT "notification_deliveries_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notification_deliveries" ADD CONSTRAINT "notification_deliveries_eventId_fkey" FOREIGN KEY ("eventId") REFERENCES "monitoring_events"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notification_deliveries" ADD CONSTRAINT "notification_deliveries_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
