-- ============================================================
-- sc_gamedata â€” FULL SCHEMA
-- Safe to re-run at any time:
--   CREATE TABLE IF NOT EXISTS â†’ skips existing tables, IDs unchanged
--   FK constraints are inline â†’ no ALTER TABLE, no duplicate errors
--   Data import (Invoke-SqlImport.ps1) handles upserts separately
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- A. FOUNDATION
-- ============================================================

CREATE TABLE IF NOT EXISTS `companies` (
  `company_id`    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `company_name`  VARCHAR(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `company_code`  VARCHAR(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `uuid`              VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  `date_added`    INT DEFAULT NULL,
  `date_modified` INT DEFAULT NULL,
  PRIMARY KEY (`company_id`),
  UNIQUE KEY `uq_companies_uuid` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `industries` (
  `industry_id`   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `industry_name` VARCHAR(255) COLLATE utf8mb4_general_ci NOT NULL,
  `uuid`              VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`industry_id`),
  UNIQUE KEY `uq_industries_uuid` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `company_industries` (
  `company_id`  INT UNSIGNED NOT NULL,
  `industry_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`company_id`, `industry_id`),
  KEY `idx_company_industries_industry` (`industry_id`),
  CONSTRAINT `fk_company_industries_company`  FOREIGN KEY (`company_id`)  REFERENCES `companies`  (`company_id`),
  CONSTRAINT `fk_company_industries_industry` FOREIGN KEY (`industry_id`) REFERENCES `industries` (`industry_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `factions` (
  `faction_id`   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `faction_name` VARCHAR(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `uuid`             VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`faction_id`),
  UNIQUE KEY `uq_factions_uuid` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `jurisdictions` (
  `jurisdiction_id`   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `jurisdiction_name` VARCHAR(255) COLLATE utf8mb4_general_ci NOT NULL,
  `jurisdiction_code` VARCHAR(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `uuid`                  VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`jurisdiction_id`),
  UNIQUE KEY `uq_jurisdictions_uuid` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `jurisdiction_factions` (
  `jurisdiction_id` INT UNSIGNED NOT NULL,
  `faction_id`      INT UNSIGNED NOT NULL,
  PRIMARY KEY (`jurisdiction_id`, `faction_id`),
  KEY `idx_jurisdiction_factions_faction` (`faction_id`),
  CONSTRAINT `fk_jurisdiction_factions_jurisdiction` FOREIGN KEY (`jurisdiction_id`) REFERENCES `jurisdictions` (`jurisdiction_id`),
  CONSTRAINT `fk_jurisdiction_factions_faction`      FOREIGN KEY (`faction_id`)      REFERENCES `factions`      (`faction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
-- B. LOCATIONS
-- ============================================================

CREATE TABLE IF NOT EXISTS `location_types` (
  `type_id`   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `type_name` VARCHAR(100) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`type_id`),
  UNIQUE KEY `uq_location_types_name` (`type_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `locations` (
  `location_id`       INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `type_id`           INT UNSIGNED NOT NULL,
  `location_name`     VARCHAR(255) COLLATE utf8mb4_general_ci NOT NULL,
  `location_alt_name` VARCHAR(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `nav_icon`          VARCHAR(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `is_available_live` TINYINT(1)   NOT NULL DEFAULT 0,
  `uuid`                  VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  `date_added`        INT DEFAULT NULL,
  `date_modified`     INT DEFAULT NULL,
  PRIMARY KEY (`location_id`),
  UNIQUE KEY `uq_locations_uuid` (`uuid`),
  KEY `idx_locations_type` (`type_id`),
  CONSTRAINT `fk_locations_type` FOREIGN KEY (`type_id`) REFERENCES `location_types` (`type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `location_relationships` (
  `parent_id` INT UNSIGNED NOT NULL,
  `child_id`  INT UNSIGNED NOT NULL,
  PRIMARY KEY (`parent_id`, `child_id`),
  KEY `idx_location_relationships_child` (`child_id`),
  CONSTRAINT `fk_location_rel_parent` FOREIGN KEY (`parent_id`) REFERENCES `locations` (`location_id`),
  CONSTRAINT `fk_location_rel_child`  FOREIGN KEY (`child_id`)  REFERENCES `locations` (`location_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `location_factions` (
  `location_id` INT UNSIGNED NOT NULL,
  `faction_id`  INT UNSIGNED NOT NULL,
  PRIMARY KEY (`location_id`, `faction_id`),
  KEY `idx_location_factions_faction` (`faction_id`),
  CONSTRAINT `fk_location_factions_location` FOREIGN KEY (`location_id`) REFERENCES `locations` (`location_id`),
  CONSTRAINT `fk_location_factions_faction`  FOREIGN KEY (`faction_id`)  REFERENCES `factions`  (`faction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `location_jurisdictions` (
  `location_id`     INT UNSIGNED NOT NULL,
  `jurisdiction_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`location_id`, `jurisdiction_id`),
  KEY `idx_location_jurisdictions_jurisdiction` (`jurisdiction_id`),
  CONSTRAINT `fk_location_jurisdictions_location`     FOREIGN KEY (`location_id`)     REFERENCES `locations`     (`location_id`),
  CONSTRAINT `fk_location_jurisdictions_jurisdiction` FOREIGN KEY (`jurisdiction_id`) REFERENCES `jurisdictions` (`jurisdiction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `amenity_types` (
  `amenity_type_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `amenity_name`    VARCHAR(255) COLLATE utf8mb4_general_ci NOT NULL,
  `label_token`     VARCHAR(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `uuid`                VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`amenity_type_id`),
  UNIQUE KEY `uq_amenity_types_uuid` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `location_amenities` (
  `location_id`     INT UNSIGNED NOT NULL,
  `amenity_type_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`location_id`, `amenity_type_id`),
  KEY `idx_location_amenities_amenity` (`amenity_type_id`),
  CONSTRAINT `fk_location_amenities_location` FOREIGN KEY (`location_id`)     REFERENCES `locations`     (`location_id`),
  CONSTRAINT `fk_location_amenities_amenity`  FOREIGN KEY (`amenity_type_id`) REFERENCES `amenity_types` (`amenity_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
-- C. ITEMS
-- ============================================================

CREATE TABLE IF NOT EXISTS `item_category_sections` (
  `section_id`   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `section_name` VARCHAR(120) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`section_id`),
  UNIQUE KEY `uq_item_category_sections_name` (`section_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `item_categories` (
  `category_id`     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `section_id`      INT UNSIGNED DEFAULT NULL,
  `category_name`   VARCHAR(255) COLLATE utf8mb4_general_ci NOT NULL,
  `category_code`   VARCHAR(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `is_game_related` TINYINT(1)   NOT NULL DEFAULT 1,
  `date_added`      INT DEFAULT NULL,
  `date_modified`   INT DEFAULT NULL,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `uq_item_categories_name` (`category_name`),
  KEY `idx_item_categories_section` (`section_id`),
  CONSTRAINT `fk_item_categories_section` FOREIGN KEY (`section_id`) REFERENCES `item_category_sections` (`section_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `item_types` (
  `type_id`   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `type_name` VARCHAR(100) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`type_id`),
  UNIQUE KEY `uq_item_types_name` (`type_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `item_sub_types` (
  `sub_type_id`   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `type_id`       INT UNSIGNED NOT NULL,
  `sub_type_name` VARCHAR(100) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`sub_type_id`),
  UNIQUE KEY `uq_item_sub_types` (`type_id`, `sub_type_name`),
  KEY `idx_item_sub_types_type` (`type_id`),
  CONSTRAINT `fk_item_sub_types_type` FOREIGN KEY (`type_id`) REFERENCES `item_types` (`type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `tags` (
  `tag_id`   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `tag_name` VARCHAR(100) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`tag_id`),
  UNIQUE KEY `uq_tags_name` (`tag_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `items` (
  `item_id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `category_id`     INT UNSIGNED DEFAULT NULL,
  `type_id`         INT UNSIGNED DEFAULT NULL,
  `sub_type_id`     INT UNSIGNED DEFAULT NULL,
  `display_name`    VARCHAR(255) COLLATE utf8mb4_general_ci NOT NULL,
  `short_name`      VARCHAR(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `code_name`       VARCHAR(255) COLLATE utf8mb4_general_ci NOT NULL,
  `description`     TEXT COLLATE utf8mb4_general_ci,
  `size`            INT DEFAULT NULL,
  `grade`           INT DEFAULT NULL,
  `is_purchasable`  TINYINT(1) NOT NULL DEFAULT 0,
  `is_craftable`    TINYINT(1) NOT NULL DEFAULT 0,
  `is_game_related` TINYINT(1) NOT NULL DEFAULT 1,
  `uuid`                VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  `date_added`      INT DEFAULT NULL,
  `date_modified`   INT DEFAULT NULL,
  PRIMARY KEY (`item_id`),
  UNIQUE KEY `uq_items_uuid` (`uuid`),
  KEY `idx_items_category` (`category_id`),
  KEY `idx_items_type`     (`type_id`),
  KEY `idx_items_sub_type` (`sub_type_id`),
  CONSTRAINT `fk_items_category` FOREIGN KEY (`category_id`) REFERENCES `item_categories` (`category_id`),
  CONSTRAINT `fk_items_type`     FOREIGN KEY (`type_id`)     REFERENCES `item_types`       (`type_id`),
  CONSTRAINT `fk_items_sub_type` FOREIGN KEY (`sub_type_id`) REFERENCES `item_sub_types`   (`sub_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `item_manufacturers` (
  `item_id`    INT UNSIGNED NOT NULL,
  `company_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`item_id`, `company_id`),
  KEY `idx_item_manufacturers_company` (`company_id`),
  CONSTRAINT `fk_item_manufacturers_item`    FOREIGN KEY (`item_id`)    REFERENCES `items`     (`item_id`),
  CONSTRAINT `fk_item_manufacturers_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`company_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `item_tags` (
  `item_id` INT UNSIGNED NOT NULL,
  `tag_id`  INT UNSIGNED NOT NULL,
  PRIMARY KEY (`item_id`, `tag_id`),
  KEY `idx_item_tags_tag` (`tag_id`),
  CONSTRAINT `fk_item_tags_item` FOREIGN KEY (`item_id`) REFERENCES `items` (`item_id`),
  CONSTRAINT `fk_item_tags_tag`  FOREIGN KEY (`tag_id`)  REFERENCES `tags`  (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
-- D. VEHICLES
-- ============================================================

CREATE TABLE IF NOT EXISTS `vehicle_types` (
  `type_id`   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `type_name` VARCHAR(100) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`type_id`),
  UNIQUE KEY `uq_vehicle_types_name` (`type_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `vehicle_careers` (
  `career_id`   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `career_name` VARCHAR(100) COLLATE utf8mb4_general_ci NOT NULL,
  `uuid`            VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`career_id`),
  UNIQUE KEY `uq_vehicle_careers_uuid` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `vehicle_roles` (
  `role_id`   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `career_id` INT UNSIGNED DEFAULT NULL,
  `role_name` VARCHAR(100) COLLATE utf8mb4_general_ci NOT NULL,
  `uuid`          VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `uq_vehicle_roles_uuid` (`uuid`),
  KEY `idx_vehicle_roles_career` (`career_id`),
  CONSTRAINT `fk_vehicle_roles_career` FOREIGN KEY (`career_id`) REFERENCES `vehicle_careers` (`career_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `vehicle_sizes` (
  `size_id`   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `size_name` VARCHAR(50) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`size_id`),
  UNIQUE KEY `uq_vehicle_sizes_name` (`size_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `vehicles` (
  `vehicle_id`                   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `type_id`                      INT UNSIGNED DEFAULT NULL,
  `career_id`                    INT UNSIGNED DEFAULT NULL,
  `role_id`                      INT UNSIGNED DEFAULT NULL,
  `size_id`                      INT UNSIGNED DEFAULT NULL,
  `display_name`                 VARCHAR(255) COLLATE utf8mb4_general_ci NOT NULL,
  `code_name`                    VARCHAR(255) COLLATE utf8mb4_general_ci NOT NULL,
  `description`                  TEXT COLLATE utf8mb4_general_ci,
  `crew_size`                    INT DEFAULT NULL,
  `movement_class`               VARCHAR(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `dim_x`                        DECIMAL(10,2) DEFAULT NULL,
  `dim_y`                        DECIMAL(10,2) DEFAULT NULL,
  `dim_z`                        DECIMAL(10,2) DEFAULT NULL,
  `hull_damage_normalization`    INT DEFAULT NULL,
  `insurance_base_wait_min`      DECIMAL(8,2) DEFAULT NULL,
  `insurance_mandatory_wait_min` DECIMAL(8,2) DEFAULT NULL,
  `insurance_expedite_fee`       INT DEFAULT NULL,
  `can_entitle_through_website`  TINYINT(1) NOT NULL DEFAULT 0,
  `uuid`                             VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  `date_added`                   INT DEFAULT NULL,
  `date_modified`                INT DEFAULT NULL,
  PRIMARY KEY (`vehicle_id`),
  UNIQUE KEY `uq_vehicles_uuid` (`uuid`),
  KEY `idx_vehicles_type`   (`type_id`),
  KEY `idx_vehicles_career` (`career_id`),
  KEY `idx_vehicles_role`   (`role_id`),
  KEY `idx_vehicles_size`   (`size_id`),
  CONSTRAINT `fk_vehicles_type`   FOREIGN KEY (`type_id`)   REFERENCES `vehicle_types`   (`type_id`),
  CONSTRAINT `fk_vehicles_career` FOREIGN KEY (`career_id`) REFERENCES `vehicle_careers` (`career_id`),
  CONSTRAINT `fk_vehicles_role`   FOREIGN KEY (`role_id`)   REFERENCES `vehicle_roles`   (`role_id`),
  CONSTRAINT `fk_vehicles_size`   FOREIGN KEY (`size_id`)   REFERENCES `vehicle_sizes`   (`size_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `vehicle_manufacturers` (
  `vehicle_id` INT UNSIGNED NOT NULL,
  `company_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`vehicle_id`, `company_id`),
  KEY `idx_vehicle_manufacturers_company` (`company_id`),
  CONSTRAINT `fk_vehicle_manufacturers_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles`  (`vehicle_id`),
  CONSTRAINT `fk_vehicle_manufacturers_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`company_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `vehicle_relationships` (
  `parent_id` INT UNSIGNED NOT NULL,
  `child_id`  INT UNSIGNED NOT NULL,
  PRIMARY KEY (`parent_id`, `child_id`),
  KEY `idx_vehicle_relationships_child` (`child_id`),
  CONSTRAINT `fk_vehicle_rel_parent` FOREIGN KEY (`parent_id`) REFERENCES `vehicles` (`vehicle_id`),
  CONSTRAINT `fk_vehicle_rel_child`  FOREIGN KEY (`child_id`)  REFERENCES `vehicles` (`vehicle_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `component_types` (
  `component_type_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `type_name`         VARCHAR(100) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`component_type_id`),
  UNIQUE KEY `uq_component_types_name` (`type_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `component_sub_types` (
  `sub_type_id`       INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `component_type_id` INT UNSIGNED NOT NULL,
  `sub_type_name`     VARCHAR(100) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`sub_type_id`),
  UNIQUE KEY `uq_component_sub_types` (`component_type_id`, `sub_type_name`),
  KEY `idx_component_sub_types_type` (`component_type_id`),
  CONSTRAINT `fk_component_sub_types_type` FOREIGN KEY (`component_type_id`) REFERENCES `component_types` (`component_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `vehicle_hardpoints` (
  `hardpoint_id`     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `vehicle_id`       INT UNSIGNED NOT NULL,
  `code_name`        VARCHAR(255) COLLATE utf8mb4_general_ci NOT NULL,
  `display_name`     VARCHAR(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `min_size`         INT DEFAULT NULL,
  `max_size`         INT DEFAULT NULL,
  `user_replaceable` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`hardpoint_id`),
  UNIQUE KEY `uq_vehicle_hardpoints` (`vehicle_id`, `code_name`),
  KEY `idx_vehicle_hardpoints_vehicle` (`vehicle_id`),
  CONSTRAINT `fk_vehicle_hardpoints_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`vehicle_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `vehicle_hardpoint_accepted_types` (
  `hardpoint_id`      INT UNSIGNED NOT NULL,
  `component_type_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`hardpoint_id`, `component_type_id`),
  KEY `idx_vhat_component_type` (`component_type_id`),
  CONSTRAINT `fk_vhat_hardpoint`      FOREIGN KEY (`hardpoint_id`)      REFERENCES `vehicle_hardpoints` (`hardpoint_id`),
  CONSTRAINT `fk_vhat_component_type` FOREIGN KEY (`component_type_id`) REFERENCES `component_types`    (`component_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `vehicle_hardpoint_defaults` (
  `hardpoint_id`              INT UNSIGNED NOT NULL,
  `default_item_id`           INT UNSIGNED DEFAULT NULL,
  `default_component_type_id` INT UNSIGNED DEFAULT NULL,
  `default_component_size`    INT DEFAULT NULL,
  `default_component_grade`   INT DEFAULT NULL,
  PRIMARY KEY (`hardpoint_id`),
  KEY `idx_vhd_item`           (`default_item_id`),
  KEY `idx_vhd_component_type` (`default_component_type_id`),
  CONSTRAINT `fk_vhd_hardpoint`      FOREIGN KEY (`hardpoint_id`)              REFERENCES `vehicle_hardpoints` (`hardpoint_id`),
  CONSTRAINT `fk_vhd_item`           FOREIGN KEY (`default_item_id`)           REFERENCES `items`              (`item_id`),
  CONSTRAINT `fk_vhd_component_type` FOREIGN KEY (`default_component_type_id`) REFERENCES `component_types`    (`component_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `item_vehicles` (
  `item_id`    INT UNSIGNED NOT NULL,
  `vehicle_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`item_id`, `vehicle_id`),
  KEY `idx_item_vehicles_vehicle` (`vehicle_id`),
  CONSTRAINT `fk_item_vehicles_item`    FOREIGN KEY (`item_id`)    REFERENCES `items`    (`item_id`),
  CONSTRAINT `fk_item_vehicles_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`vehicle_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
-- E. COMMODITIES
-- ============================================================

CREATE TABLE IF NOT EXISTS `commodity_types` (
  `commodity_type_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `type_name`         VARCHAR(255) COLLATE utf8mb4_general_ci NOT NULL,
  `type_key`          VARCHAR(255) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`commodity_type_id`),
  UNIQUE KEY `uq_commodity_types_key` (`type_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `commodities` (
  `commodity_id`        INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `commodity_type_id`   INT UNSIGNED DEFAULT NULL,
  `display_name`        VARCHAR(255) COLLATE utf8mb4_general_ci NOT NULL,
  `code_name`           VARCHAR(255) COLLATE utf8mb4_general_ci NOT NULL,
  `resourcetype_ref`    VARCHAR(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `description`         TEXT COLLATE utf8mb4_general_ci,
  `density_gcm3`        DECIMAL(8,4)  DEFAULT NULL,
  `is_raw`              TINYINT(1) NOT NULL DEFAULT 0,
  `is_refinable`        TINYINT(1) NOT NULL DEFAULT 0,
  `is_pure`             TINYINT(1) NOT NULL DEFAULT 0,
  `is_mineable`         TINYINT(1) NOT NULL DEFAULT 0,
  `is_harvestable`      TINYINT(1) NOT NULL DEFAULT 0,
  `is_salvageable`      TINYINT(1) NOT NULL DEFAULT 0,
  `is_explosive`        TINYINT(1) NOT NULL DEFAULT 0,
  `is_volatile_quantum` TINYINT(1) NOT NULL DEFAULT 0,
  `is_available_live`   TINYINT(1) NOT NULL DEFAULT 0,
  `uuid`                    VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  `date_added`          INT DEFAULT NULL,
  `date_modified`       INT DEFAULT NULL,
  PRIMARY KEY (`commodity_id`),
  UNIQUE KEY `uq_commodities_uuid`       (`uuid`),
  UNIQUE KEY `uq_commodities_resourcetype` (`resourcetype_ref`),
  KEY `idx_commodities_type`               (`commodity_type_id`),
  CONSTRAINT `fk_commodities_type` FOREIGN KEY (`commodity_type_id`) REFERENCES `commodity_types` (`commodity_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `commodity_relationships` (
  `parent_id`         INT UNSIGNED NOT NULL,
  `child_id`          INT UNSIGNED NOT NULL,
  `relationship_type` ENUM('refines_into','salvage_refines_into') NOT NULL DEFAULT 'refines_into',
  PRIMARY KEY (`parent_id`, `child_id`),
  KEY `idx_commodity_rel_child` (`child_id`),
  CONSTRAINT `fk_commodity_rel_parent` FOREIGN KEY (`parent_id`) REFERENCES `commodities` (`commodity_id`),
  CONSTRAINT `fk_commodity_rel_child`  FOREIGN KEY (`child_id`)  REFERENCES `commodities` (`commodity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `commodity_illegal_jurisdictions` (
  `commodity_id`    INT UNSIGNED NOT NULL,
  `jurisdiction_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`commodity_id`, `jurisdiction_id`),
  KEY `idx_commodity_illegal_jurisdiction` (`jurisdiction_id`),
  CONSTRAINT `fk_commodity_illegal_commodity`    FOREIGN KEY (`commodity_id`)    REFERENCES `commodities`   (`commodity_id`),
  CONSTRAINT `fk_commodity_illegal_jurisdiction` FOREIGN KEY (`jurisdiction_id`) REFERENCES `jurisdictions` (`jurisdiction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
-- F. MINING
-- ============================================================

CREATE TABLE IF NOT EXISTS `mining_modes` (
  `mode_id`   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `mode_name` VARCHAR(50) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`mode_id`),
  UNIQUE KEY `uq_mining_modes_name` (`mode_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `mining_contexts` (
  `context_id`   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `context_name` VARCHAR(50) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`context_id`),
  UNIQUE KEY `uq_mining_contexts_name` (`context_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `mineable_elements` (
  `element_id`                INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `commodity_id`              INT UNSIGNED NOT NULL,
  `mode_id`                   INT UNSIGNED DEFAULT NULL,
  `instability_rating`        INT DEFAULT NULL,
  `resistance`                INT DEFAULT NULL,
  `explosion_multiplier`      DECIMAL(8,3) DEFAULT NULL,
  `cluster_factor`            DECIMAL(8,3) DEFAULT NULL,
  `optimal_window_midpoint`   DECIMAL(8,3) DEFAULT NULL,
  `optimal_window_randomness` DECIMAL(8,3) DEFAULT NULL,
  `optimal_window_thinness`   DECIMAL(8,3) DEFAULT NULL,
  `uuid`                          VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`element_id`),
  UNIQUE KEY `uq_mineable_elements_uuid` (`uuid`),
  KEY `idx_mineable_elements_commodity` (`commodity_id`),
  KEY `idx_mineable_elements_mode`      (`mode_id`),
  CONSTRAINT `fk_mineable_elements_commodity` FOREIGN KEY (`commodity_id`) REFERENCES `commodities`  (`commodity_id`),
  CONSTRAINT `fk_mineable_elements_mode`      FOREIGN KEY (`mode_id`)      REFERENCES `mining_modes` (`mode_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `mineable_element_contexts` (
  `element_id` INT UNSIGNED NOT NULL,
  `context_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`element_id`, `context_id`),
  KEY `idx_mineable_element_contexts_context` (`context_id`),
  CONSTRAINT `fk_mec_element` FOREIGN KEY (`element_id`) REFERENCES `mineable_elements` (`element_id`),
  CONSTRAINT `fk_mec_context` FOREIGN KEY (`context_id`) REFERENCES `mining_contexts`   (`context_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `mineable_element_density_profiles` (
  `element_id`      INT UNSIGNED NOT NULL,
  `context_id`      INT UNSIGNED NOT NULL,
  `default_mass`    DECIMAL(10,4) DEFAULT NULL,
  `cscu_per_volume` DECIMAL(10,6) DEFAULT NULL,
  `mass_per_scu`    DECIMAL(10,4) DEFAULT NULL,
  PRIMARY KEY (`element_id`, `context_id`),
  KEY `idx_medp_context` (`context_id`),
  CONSTRAINT `fk_medp_element` FOREIGN KEY (`element_id`) REFERENCES `mineable_elements` (`element_id`),
  CONSTRAINT `fk_medp_context` FOREIGN KEY (`context_id`) REFERENCES `mining_contexts`   (`context_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `rock_compositions` (
  `composition_id`        INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `deposit_name`          VARCHAR(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `context_id`            INT UNSIGNED DEFAULT NULL,
  `rarity`                VARCHAR(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `min_distinct_elements` INT DEFAULT NULL,
  `uuid`                      VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`composition_id`),
  UNIQUE KEY `uq_rock_compositions_uuid` (`uuid`),
  KEY `idx_rock_compositions_context` (`context_id`),
  CONSTRAINT `fk_rock_compositions_context` FOREIGN KEY (`context_id`) REFERENCES `mining_contexts` (`context_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `rock_composition_elements` (
  `composition_id` INT UNSIGNED NOT NULL,
  `element_id`     INT UNSIGNED NOT NULL,
  `slot_index`     INT NOT NULL,
  `min_percentage` DECIMAL(8,4) DEFAULT NULL,
  `max_percentage` DECIMAL(8,4) DEFAULT NULL,
  `probability`    DECIMAL(8,4) DEFAULT NULL,
  `quality_scale`  DECIMAL(8,4) DEFAULT NULL,
  `curve_exponent` DECIMAL(8,4) DEFAULT NULL,
  PRIMARY KEY (`composition_id`, `element_id`, `slot_index`),
  KEY `idx_rce_element` (`element_id`),
  CONSTRAINT `fk_rce_composition` FOREIGN KEY (`composition_id`) REFERENCES `rock_compositions` (`composition_id`),
  CONSTRAINT `fk_rce_element`     FOREIGN KEY (`element_id`)     REFERENCES `mineable_elements` (`element_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `clustering_presets` (
  `preset_id`                 INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `code_name`                 VARCHAR(255) COLLATE utf8mb4_general_ci NOT NULL,
  `category`                  ENUM('mining','salvage') NOT NULL DEFAULT 'mining',
  `rarity`                    VARCHAR(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `tier`                      VARCHAR(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `probability_of_clustering` DECIMAL(8,4) DEFAULT NULL,
  `expected_cluster_size`     DECIMAL(8,2) DEFAULT NULL,
  `uuid`                          VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`preset_id`),
  UNIQUE KEY `uq_clustering_presets_uuid` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `clustering_preset_slots` (
  `slot_id`              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `preset_id`            INT UNSIGNED NOT NULL,
  `slot_index`           INT NOT NULL,
  `relative_probability` DECIMAL(8,4) DEFAULT NULL,
  `min_size`             INT DEFAULT NULL,
  `max_size`             INT DEFAULT NULL,
  `min_proximity`        DECIMAL(10,2) DEFAULT NULL,
  `max_proximity`        DECIMAL(10,2) DEFAULT NULL,
  PRIMARY KEY (`slot_id`),
  UNIQUE KEY `uq_clustering_preset_slots` (`preset_id`, `slot_index`),
  KEY `idx_clustering_preset_slots_preset` (`preset_id`),
  CONSTRAINT `fk_clustering_preset_slots_preset` FOREIGN KEY (`preset_id`) REFERENCES `clustering_presets` (`preset_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `mineable_locations` (
  `location_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `system`      VARCHAR(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `body_name`   VARCHAR(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `uuid`            VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`location_id`),
  UNIQUE KEY `uq_mineable_locations_uuid` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `mineable_location_groups` (
  `group_id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `location_id`       INT UNSIGNED NOT NULL,
  `group_name`        VARCHAR(255) COLLATE utf8mb4_general_ci NOT NULL,
  `group_probability` DECIMAL(8,4) DEFAULT NULL,
  PRIMARY KEY (`group_id`),
  UNIQUE KEY `uq_mineable_location_groups` (`location_id`, `group_name`),
  KEY `idx_mlg_location` (`location_id`),
  CONSTRAINT `fk_mlg_location` FOREIGN KEY (`location_id`) REFERENCES `mineable_locations` (`location_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `mineable_location_group_entries` (
  `entry_id`                  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `group_id`                  INT UNSIGNED NOT NULL,
  `composition_id`            INT UNSIGNED NOT NULL,
  `clustering_preset_id`      INT UNSIGNED DEFAULT NULL,
  `relative_probability`      DECIMAL(10,4) DEFAULT NULL,
  `probability_of_clustering` DECIMAL(8,4) DEFAULT NULL,
  `expected_cluster_size`     DECIMAL(8,2) DEFAULT NULL,
  PRIMARY KEY (`entry_id`),
  UNIQUE KEY `uq_mlge` (`group_id`, `composition_id`),
  KEY `idx_mlge_composition`       (`composition_id`),
  KEY `idx_mlge_clustering_preset` (`clustering_preset_id`),
  CONSTRAINT `fk_mlge_group`             FOREIGN KEY (`group_id`)             REFERENCES `mineable_location_groups` (`group_id`),
  CONSTRAINT `fk_mlge_composition`       FOREIGN KEY (`composition_id`)       REFERENCES `rock_compositions`        (`composition_id`),
  CONSTRAINT `fk_mlge_clustering_preset` FOREIGN KEY (`clustering_preset_id`) REFERENCES `clustering_presets`       (`preset_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
-- G. SALVAGE
-- ============================================================

CREATE TABLE IF NOT EXISTS `salvageable_resources` (
  `salvageable_resource_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `commodity_id`            INT UNSIGNED NOT NULL,
  `uuid`                        VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`salvageable_resource_id`),
  UNIQUE KEY `uq_salvageable_resources_uuid`    (`uuid`),
  UNIQUE KEY `uq_salvageable_resources_commodity` (`commodity_id`),
  CONSTRAINT `fk_salvageable_resources_commodity` FOREIGN KEY (`commodity_id`) REFERENCES `commodities` (`commodity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `salvageable_resource_ships` (
  `salvageable_resource_id` INT UNSIGNED NOT NULL,
  `item_id`                 INT UNSIGNED NOT NULL,
  PRIMARY KEY (`salvageable_resource_id`, `item_id`),
  KEY `idx_salvageable_resource_ships_item` (`item_id`),
  CONSTRAINT `fk_salvageable_resource_ships_resource` FOREIGN KEY (`salvageable_resource_id`) REFERENCES `salvageable_resources` (`salvageable_resource_id`),
  CONSTRAINT `fk_salvageable_resource_ships_item`     FOREIGN KEY (`item_id`)                 REFERENCES `items`                (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `salvageable_presets` (
  `preset_id`        INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `display_name`     VARCHAR(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `vehicle_id`       INT UNSIGNED DEFAULT NULL,
  `respawn_time_sec` INT DEFAULT NULL,
  `despawn_time_sec` INT DEFAULT NULL,
  `wait_time_sec`    INT DEFAULT NULL,
  `uuid`                 VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`preset_id`),
  UNIQUE KEY `uq_salvageable_presets_uuid` (`uuid`),
  KEY `idx_salvageable_presets_vehicle` (`vehicle_id`),
  CONSTRAINT `fk_salvageable_presets_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`vehicle_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `salvageable_preset_conditions` (
  `condition_id`    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `preset_id`       INT UNSIGNED NOT NULL,
  `condition_type`  VARCHAR(100) COLLATE utf8mb4_general_ci NOT NULL,
  `attribute_name`  VARCHAR(100) COLLATE utf8mb4_general_ci NOT NULL,
  `attribute_value` DECIMAL(10,4) DEFAULT NULL,
  PRIMARY KEY (`condition_id`),
  KEY `idx_salvageable_preset_conditions_preset` (`preset_id`),
  CONSTRAINT `fk_salvageable_preset_conditions_preset` FOREIGN KEY (`preset_id`) REFERENCES `salvageable_presets` (`preset_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
-- H. TERMINALS & PRICES
-- ============================================================

CREATE TABLE IF NOT EXISTS `terminal_types` (
  `terminal_type_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `type_name`        VARCHAR(100) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`terminal_type_id`),
  UNIQUE KEY `uq_terminal_types_name` (`type_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `shop_templates` (
  `shop_template_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `shop_code`        VARCHAR(255) COLLATE utf8mb4_general_ci NOT NULL,
  `terminal_type_id` INT UNSIGNED DEFAULT NULL,
  `uuid`                 VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`shop_template_id`),
  UNIQUE KEY `uq_shop_templates_uuid`    (`uuid`),
  UNIQUE KEY `uq_shop_templates_shop_code` (`shop_code`),
  KEY `idx_shop_templates_type` (`terminal_type_id`),
  CONSTRAINT `fk_shop_templates_type` FOREIGN KEY (`terminal_type_id`) REFERENCES `terminal_types` (`terminal_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `terminals` (
  `terminal_id`       INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `shop_template_id`  INT UNSIGNED DEFAULT NULL,
  `location_id`       INT UNSIGNED DEFAULT NULL,
  `faction_id`        INT UNSIGNED DEFAULT NULL,
  `company_id`        INT UNSIGNED DEFAULT NULL,
  `terminal_name`     VARCHAR(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `terminal_nickname` VARCHAR(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `is_available_live` INT NOT NULL DEFAULT 0,
  `uuid`                  VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  `date_added`        INT DEFAULT NULL,
  `date_modified`     INT DEFAULT NULL,
  PRIMARY KEY (`terminal_id`),
  UNIQUE KEY `uq_terminals_uuid` (`uuid`),
  KEY `idx_terminals_shop_template` (`shop_template_id`),
  KEY `idx_terminals_location`      (`location_id`),
  KEY `idx_terminals_faction`       (`faction_id`),
  KEY `idx_terminals_company`       (`company_id`),
  CONSTRAINT `fk_terminals_shop_template` FOREIGN KEY (`shop_template_id`) REFERENCES `shop_templates` (`shop_template_id`),
  CONSTRAINT `fk_terminals_location`      FOREIGN KEY (`location_id`)      REFERENCES `locations`      (`location_id`),
  CONSTRAINT `fk_terminals_faction`       FOREIGN KEY (`faction_id`)       REFERENCES `factions`       (`faction_id`),
  CONSTRAINT `fk_terminals_company`       FOREIGN KEY (`company_id`)       REFERENCES `companies`      (`company_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `commodity_prices` (
  `price_id`      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `commodity_id`  INT UNSIGNED NOT NULL,
  `terminal_id`   INT UNSIGNED NOT NULL,
  `price_buy`     DECIMAL(14,4) DEFAULT NULL,
  `price_sell`    DECIMAL(14,4) DEFAULT NULL,
  `date_added`    INT DEFAULT NULL,
  `date_modified` INT DEFAULT NULL,
  PRIMARY KEY (`price_id`),
  UNIQUE KEY `uq_commodity_prices` (`commodity_id`, `terminal_id`),
  KEY `idx_commodity_prices_terminal` (`terminal_id`),
  CONSTRAINT `fk_commodity_prices_commodity` FOREIGN KEY (`commodity_id`) REFERENCES `commodities` (`commodity_id`),
  CONSTRAINT `fk_commodity_prices_terminal`  FOREIGN KEY (`terminal_id`)  REFERENCES `terminals`   (`terminal_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `commodity_price_unit_sizes` (
  `price_id`      INT UNSIGNED NOT NULL,
  `unit_size_scu` INT NOT NULL,
  PRIMARY KEY (`price_id`, `unit_size_scu`),
  CONSTRAINT `fk_commodity_price_unit_sizes_price` FOREIGN KEY (`price_id`) REFERENCES `commodity_prices` (`price_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `item_prices` (
  `price_id`      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `item_id`       INT UNSIGNED NOT NULL,
  `terminal_id`   INT UNSIGNED NOT NULL,
  `price_buy`     DECIMAL(14,4) DEFAULT NULL,
  `price_sell`    DECIMAL(14,4) DEFAULT NULL,
  `date_added`    INT DEFAULT NULL,
  `date_modified` INT DEFAULT NULL,
  PRIMARY KEY (`price_id`),
  UNIQUE KEY `uq_item_prices` (`item_id`, `terminal_id`),
  KEY `idx_item_prices_terminal` (`terminal_id`),
  CONSTRAINT `fk_item_prices_item`     FOREIGN KEY (`item_id`)     REFERENCES `items`     (`item_id`),
  CONSTRAINT `fk_item_prices_terminal` FOREIGN KEY (`terminal_id`) REFERENCES `terminals` (`terminal_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `vehicle_purchase_prices` (
  `price_id`      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `vehicle_id`    INT UNSIGNED NOT NULL,
  `terminal_id`   INT UNSIGNED NOT NULL,
  `price_buy`     DECIMAL(14,4) DEFAULT NULL,
  `price_sell`    DECIMAL(14,4) DEFAULT NULL,
  `date_added`    INT DEFAULT NULL,
  `date_modified` INT DEFAULT NULL,
  PRIMARY KEY (`price_id`),
  UNIQUE KEY `uq_vehicle_purchase_prices` (`vehicle_id`, `terminal_id`),
  KEY `idx_vehicle_purchase_prices_terminal` (`terminal_id`),
  CONSTRAINT `fk_vehicle_purchase_prices_vehicle`  FOREIGN KEY (`vehicle_id`)  REFERENCES `vehicles`  (`vehicle_id`),
  CONSTRAINT `fk_vehicle_purchase_prices_terminal` FOREIGN KEY (`terminal_id`) REFERENCES `terminals` (`terminal_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `vehicle_rental_prices` (
  `price_id`      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `vehicle_id`    INT UNSIGNED NOT NULL,
  `terminal_id`   INT UNSIGNED NOT NULL,
  `price_rent`    DECIMAL(14,4) DEFAULT NULL,
  `date_added`    INT DEFAULT NULL,
  `date_modified` INT DEFAULT NULL,
  PRIMARY KEY (`price_id`),
  UNIQUE KEY `uq_vehicle_rental_prices` (`vehicle_id`, `terminal_id`),
  KEY `idx_vehicle_rental_prices_terminal` (`terminal_id`),
  CONSTRAINT `fk_vehicle_rental_prices_vehicle`  FOREIGN KEY (`vehicle_id`)  REFERENCES `vehicles`  (`vehicle_id`),
  CONSTRAINT `fk_vehicle_rental_prices_terminal` FOREIGN KEY (`terminal_id`) REFERENCES `terminals` (`terminal_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `refinery_methods` (
  `method_id`        INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid`                 VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  `code_name`        VARCHAR(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `display_name`     VARCHAR(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `description`      TEXT COLLATE utf8mb4_general_ci DEFAULT NULL,
  `refining_speed`   VARCHAR(50)  COLLATE utf8mb4_general_ci DEFAULT NULL,
  `refining_quality` VARCHAR(50)  COLLATE utf8mb4_general_ci DEFAULT NULL,
  `speed_tier`       VARCHAR(50)  COLLATE utf8mb4_general_ci DEFAULT NULL,
  `cost_tier`        VARCHAR(50)  COLLATE utf8mb4_general_ci DEFAULT NULL,
  `yield_tier`       VARCHAR(50)  COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`method_id`),
  UNIQUE KEY `uq_refinery_methods_uuid` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `refinery_yields` (
  `yield_id`      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `commodity_id`  INT UNSIGNED NOT NULL,
  `terminal_id`   INT UNSIGNED NOT NULL,
  `yield_value`   INT DEFAULT NULL,
  `uuid`              VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  `date_added`    INT DEFAULT NULL,
  `date_modified` INT DEFAULT NULL,
  PRIMARY KEY (`yield_id`),
  UNIQUE KEY `uq_refinery_yields_uuid` (`uuid`),
  UNIQUE KEY `uq_refinery_yields`        (`commodity_id`, `terminal_id`),
  KEY `idx_refinery_yields_terminal`     (`terminal_id`),
  CONSTRAINT `fk_refinery_yields_commodity` FOREIGN KEY (`commodity_id`) REFERENCES `commodities` (`commodity_id`),
  CONSTRAINT `fk_refinery_yields_terminal`  FOREIGN KEY (`terminal_id`)  REFERENCES `terminals`   (`terminal_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
-- I. MISSIONS
-- ============================================================

CREATE TABLE IF NOT EXISTS `mission_types` (
  `type_id`   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `type_name` VARCHAR(255) COLLATE utf8mb4_general_ci NOT NULL,
  `uuid`          VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`type_id`),
  UNIQUE KEY `uq_mission_types_uuid` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `mission_givers` (
  `giver_id`       INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `code_name`      VARCHAR(255) COLLATE utf8mb4_general_ci NOT NULL,
  `display_name`   VARCHAR(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `reputation_ref` VARCHAR(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `uuid`               VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`giver_id`),
  UNIQUE KEY `uq_mission_givers_uuid` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `mission_giver_factions` (
  `giver_id`   INT UNSIGNED NOT NULL,
  `faction_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`giver_id`, `faction_id`),
  KEY `idx_mission_giver_factions_faction` (`faction_id`),
  CONSTRAINT `fk_mission_giver_factions_giver`   FOREIGN KEY (`giver_id`)   REFERENCES `mission_givers` (`giver_id`),
  CONSTRAINT `fk_mission_giver_factions_faction` FOREIGN KEY (`faction_id`) REFERENCES `factions`       (`faction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `missions` (
  `mission_id`    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `type_id`       INT UNSIGNED DEFAULT NULL,
  `giver_id`      INT UNSIGNED DEFAULT NULL,
  `display_name`  VARCHAR(255) COLLATE utf8mb4_general_ci NOT NULL,
  `description`   TEXT COLLATE utf8mb4_general_ci,
  `uuid`              VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  `date_added`    INT DEFAULT NULL,
  `date_modified` INT DEFAULT NULL,
  PRIMARY KEY (`mission_id`),
  UNIQUE KEY `uq_missions_uuid` (`uuid`),
  KEY `idx_missions_type`  (`type_id`),
  KEY `idx_missions_giver` (`giver_id`),
  CONSTRAINT `fk_missions_type`  FOREIGN KEY (`type_id`)  REFERENCES `mission_types`  (`type_id`),
  CONSTRAINT `fk_missions_giver` FOREIGN KEY (`giver_id`) REFERENCES `mission_givers` (`giver_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `mission_locations` (
  `mission_id`  INT UNSIGNED NOT NULL,
  `location_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`mission_id`, `location_id`),
  KEY `idx_mission_locations_location` (`location_id`),
  CONSTRAINT `fk_mission_locations_mission`  FOREIGN KEY (`mission_id`)  REFERENCES `missions`  (`mission_id`),
  CONSTRAINT `fk_mission_locations_location` FOREIGN KEY (`location_id`) REFERENCES `locations` (`location_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `mission_rewards` (
  `reward_id`   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `mission_id`  INT UNSIGNED NOT NULL,
  `reward_type` VARCHAR(100) COLLATE utf8mb4_general_ci NOT NULL,
  `value`       DECIMAL(14,2) DEFAULT NULL,
  `item_id`     INT UNSIGNED DEFAULT NULL,
  `uuid`            VARCHAR(36)  COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`reward_id`),
  KEY `idx_mission_rewards_mission` (`mission_id`),
  KEY `idx_mission_rewards_item`    (`item_id`),
  CONSTRAINT `fk_mission_rewards_mission` FOREIGN KEY (`mission_id`) REFERENCES `missions` (`mission_id`),
  CONSTRAINT `fk_mission_rewards_item`    FOREIGN KEY (`item_id`)    REFERENCES `items`    (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
-- J. CRAFTING
-- ============================================================

CREATE TABLE IF NOT EXISTS `blueprints` (
  `blueprint_id`   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `display_name`   VARCHAR(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `result_item_id` INT UNSIGNED NOT NULL,
  `quantity`       INT NOT NULL DEFAULT 1,
  `uuid`               VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  `date_added`     INT DEFAULT NULL,
  `date_modified`  INT DEFAULT NULL,
  PRIMARY KEY (`blueprint_id`),
  UNIQUE KEY `uq_blueprints_uuid` (`uuid`),
  KEY `idx_blueprints_result_item` (`result_item_id`),
  CONSTRAINT `fk_blueprints_result_item` FOREIGN KEY (`result_item_id`) REFERENCES `items` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `blueprint_ingredients` (
  `ingredient_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `blueprint_id`  INT UNSIGNED NOT NULL,
  `commodity_id`  INT UNSIGNED DEFAULT NULL,
  `item_id`       INT UNSIGNED DEFAULT NULL,
  `quantity`      DECIMAL(10,2) NOT NULL DEFAULT 1,
  PRIMARY KEY (`ingredient_id`),
  UNIQUE KEY `uq_blueprint_ingredients` (`blueprint_id`, `commodity_id`, `item_id`),
  KEY `idx_blueprint_ingredients_commodity` (`commodity_id`),
  KEY `idx_blueprint_ingredients_item`      (`item_id`),
  CONSTRAINT `fk_blueprint_ingredients_blueprint` FOREIGN KEY (`blueprint_id`) REFERENCES `blueprints`  (`blueprint_id`),
  CONSTRAINT `fk_blueprint_ingredients_commodity` FOREIGN KEY (`commodity_id`) REFERENCES `commodities` (`commodity_id`),
  CONSTRAINT `fk_blueprint_ingredients_item`      FOREIGN KEY (`item_id`)      REFERENCES `items`       (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `blueprint_reward_pools` (
  `pool_id`       INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `pool_name`     VARCHAR(255) COLLATE utf8mb4_general_ci NOT NULL,
  `uuid`              VARCHAR(36)  COLLATE utf8mb4_general_ci NOT NULL,
  `date_added`    INT DEFAULT NULL,
  `date_modified` INT DEFAULT NULL,
  PRIMARY KEY (`pool_id`),
  UNIQUE KEY `uq_blueprint_reward_pools_uuid` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `blueprint_reward_pool_entries` (
  `pool_id`      INT UNSIGNED NOT NULL,
  `blueprint_id` INT UNSIGNED NOT NULL,
  `weight`       DECIMAL(8,4) DEFAULT NULL,
  PRIMARY KEY (`pool_id`, `blueprint_id`),
  KEY `idx_blueprint_reward_pool_entries_blueprint` (`blueprint_id`),
  CONSTRAINT `fk_brpe_pool`      FOREIGN KEY (`pool_id`)      REFERENCES `blueprint_reward_pools` (`pool_id`),
  CONSTRAINT `fk_brpe_blueprint` FOREIGN KEY (`blueprint_id`) REFERENCES `blueprints`             (`blueprint_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

SET FOREIGN_KEY_CHECKS = 1;

