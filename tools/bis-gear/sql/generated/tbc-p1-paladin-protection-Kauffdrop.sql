-- TBC Phase 1 BiS mail SQL
-- Spec: paladin-protection
-- Character: Kauffdrop
-- Generated: 2026-04-19T15:35:43Z

-- AzerothCore: run on the `characters` database (backup first).
-- Target character: Kauffdrop
-- Items: 17
-- If you see SQL Error 1213 (deadlock): stop `worldserver`, run again, or retry once.
-- Repeated MAX(guid)/MAX(id) per row competes with the live server; this script prefetches once.

SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;

-- Resolve recipient (case-insensitive; WoW stores mixed-case names).
-- If this returns no rows, you are on the wrong DB or the name is wrong:
--   SELECT `guid`, `name` FROM `characters` WHERE LOWER(`name`) = LOWER('Kauffdrop');
SET @receiver := (SELECT `guid` FROM `characters` WHERE LOWER(`name`) = LOWER('Kauffdrop') LIMIT 1);
-- Fail before inserts if not found (otherwise owner_guid would be NULL):
SELECT 1 / IF(@receiver IS NULL, 0, 1) AS `character_must_exist`;

-- Allocate guids/mail ids sequentially (two index scans instead of one per item).
SET @next_item_guid := (SELECT IFNULL(MAX(`guid`), 0) FROM `item_instance`);
SET @next_mail_id := (SELECT IFNULL(MAX(`id`), 0) FROM `mail`);

-- Mail batch 1 (items 1..12 of 17)
SET @next_item_guid := @next_item_guid + 1;
SET @ig_0_1 := @next_item_guid;
INSERT INTO `item_instance` (`guid`, `itemEntry`, `owner_guid`, `creatorGuid`, `giftCreatorGuid`, `count`, `duration`, `charges`, `flags`, `enchantments`, `randomPropertyId`, `durability`, `playedTime`, `text`)
VALUES (@ig_0_1, 29068, @receiver, 0, 0, 1, 0, NULL, 0, '', 0, 0, 0, NULL);

SET @next_item_guid := @next_item_guid + 1;
SET @ig_0_2 := @next_item_guid;
INSERT INTO `item_instance` (`guid`, `itemEntry`, `owner_guid`, `creatorGuid`, `giftCreatorGuid`, `count`, `duration`, `charges`, `flags`, `enchantments`, `randomPropertyId`, `durability`, `playedTime`, `text`)
VALUES (@ig_0_2, 28516, @receiver, 0, 0, 1, 0, NULL, 0, '', 0, 0, 0, NULL);

SET @next_item_guid := @next_item_guid + 1;
SET @ig_0_3 := @next_item_guid;
INSERT INTO `item_instance` (`guid`, `itemEntry`, `owner_guid`, `creatorGuid`, `giftCreatorGuid`, `count`, `duration`, `charges`, `flags`, `enchantments`, `randomPropertyId`, `durability`, `playedTime`, `text`)
VALUES (@ig_0_3, 29070, @receiver, 0, 0, 1, 0, NULL, 0, '', 0, 0, 0, NULL);

SET @next_item_guid := @next_item_guid + 1;
SET @ig_0_4 := @next_item_guid;
INSERT INTO `item_instance` (`guid`, `itemEntry`, `owner_guid`, `creatorGuid`, `giftCreatorGuid`, `count`, `duration`, `charges`, `flags`, `enchantments`, `randomPropertyId`, `durability`, `playedTime`, `text`)
VALUES (@ig_0_4, 28660, @receiver, 0, 0, 1, 0, NULL, 0, '', 0, 0, 0, NULL);

SET @next_item_guid := @next_item_guid + 1;
SET @ig_0_5 := @next_item_guid;
INSERT INTO `item_instance` (`guid`, `itemEntry`, `owner_guid`, `creatorGuid`, `giftCreatorGuid`, `count`, `duration`, `charges`, `flags`, `enchantments`, `randomPropertyId`, `durability`, `playedTime`, `text`)
VALUES (@ig_0_5, 29066, @receiver, 0, 0, 1, 0, NULL, 0, '', 0, 0, 0, NULL);

SET @next_item_guid := @next_item_guid + 1;
SET @ig_0_6 := @next_item_guid;
INSERT INTO `item_instance` (`guid`, `itemEntry`, `owner_guid`, `creatorGuid`, `giftCreatorGuid`, `count`, `duration`, `charges`, `flags`, `enchantments`, `randomPropertyId`, `durability`, `playedTime`, `text`)
VALUES (@ig_0_6, 23538, @receiver, 0, 0, 1, 0, NULL, 0, '', 0, 0, 0, NULL);

SET @next_item_guid := @next_item_guid + 1;
SET @ig_0_7 := @next_item_guid;
INSERT INTO `item_instance` (`guid`, `itemEntry`, `owner_guid`, `creatorGuid`, `giftCreatorGuid`, `count`, `duration`, `charges`, `flags`, `enchantments`, `randomPropertyId`, `durability`, `playedTime`, `text`)
VALUES (@ig_0_7, 28518, @receiver, 0, 0, 1, 0, NULL, 0, '', 0, 0, 0, NULL);

SET @next_item_guid := @next_item_guid + 1;
SET @ig_0_8 := @next_item_guid;
INSERT INTO `item_instance` (`guid`, `itemEntry`, `owner_guid`, `creatorGuid`, `giftCreatorGuid`, `count`, `duration`, `charges`, `flags`, `enchantments`, `randomPropertyId`, `durability`, `playedTime`, `text`)
VALUES (@ig_0_8, 28566, @receiver, 0, 0, 1, 0, NULL, 0, '', 0, 0, 0, NULL);

SET @next_item_guid := @next_item_guid + 1;
SET @ig_0_9 := @next_item_guid;
INSERT INTO `item_instance` (`guid`, `itemEntry`, `owner_guid`, `creatorGuid`, `giftCreatorGuid`, `count`, `duration`, `charges`, `flags`, `enchantments`, `randomPropertyId`, `durability`, `playedTime`, `text`)
VALUES (@ig_0_9, 29069, @receiver, 0, 0, 1, 0, NULL, 0, '', 0, 0, 0, NULL);

SET @next_item_guid := @next_item_guid + 1;
SET @ig_0_10 := @next_item_guid;
INSERT INTO `item_instance` (`guid`, `itemEntry`, `owner_guid`, `creatorGuid`, `giftCreatorGuid`, `count`, `duration`, `charges`, `flags`, `enchantments`, `randomPropertyId`, `durability`, `playedTime`, `text`)
VALUES (@ig_0_10, 30641, @receiver, 0, 0, 1, 0, NULL, 0, '', 0, 0, 0, NULL);

SET @next_item_guid := @next_item_guid + 1;
SET @ig_0_11 := @next_item_guid;
INSERT INTO `item_instance` (`guid`, `itemEntry`, `owner_guid`, `creatorGuid`, `giftCreatorGuid`, `count`, `duration`, `charges`, `flags`, `enchantments`, `randomPropertyId`, `durability`, `playedTime`, `text`)
VALUES (@ig_0_11, 29279, @receiver, 0, 0, 1, 0, NULL, 0, '', 0, 0, 0, NULL);

SET @next_item_guid := @next_item_guid + 1;
SET @ig_0_12 := @next_item_guid;
INSERT INTO `item_instance` (`guid`, `itemEntry`, `owner_guid`, `creatorGuid`, `giftCreatorGuid`, `count`, `duration`, `charges`, `flags`, `enchantments`, `randomPropertyId`, `durability`, `playedTime`, `text`)
VALUES (@ig_0_12, 28792, @receiver, 0, 0, 1, 0, NULL, 0, '', 0, 0, 0, NULL);

SET @next_mail_id := @next_mail_id + 1;
SET @mid := @next_mail_id;
INSERT INTO `mail` (`id`, `messageType`, `stationery`, `mailTemplateId`, `sender`, `receiver`, `subject`, `body`, `has_items`, `expire_time`, `deliver_time`, `money`, `cod`, `checked`)
VALUES (@mid, 0, 41, 0, 0, @receiver, 'TBC P1 BiS paladin-protection (part 1)', 'Granted by Export-BisSql.ps1 - claim from mailbox.', 1, UNIX_TIMESTAMP() + 86400 * 30, UNIX_TIMESTAMP(), 0, 0, 0);

INSERT INTO `mail_items` (`mail_id`, `item_guid`, `receiver`) VALUES (@mid, @ig_0_1, @receiver),
(@mid, @ig_0_2, @receiver),
(@mid, @ig_0_3, @receiver),
(@mid, @ig_0_4, @receiver),
(@mid, @ig_0_5, @receiver),
(@mid, @ig_0_6, @receiver),
(@mid, @ig_0_7, @receiver),
(@mid, @ig_0_8, @receiver),
(@mid, @ig_0_9, @receiver),
(@mid, @ig_0_10, @receiver),
(@mid, @ig_0_11, @receiver),
(@mid, @ig_0_12, @receiver);

-- Mail batch 2 (items 13..17 of 17)
SET @next_item_guid := @next_item_guid + 1;
SET @ig_12_1 := @next_item_guid;
INSERT INTO `item_instance` (`guid`, `itemEntry`, `owner_guid`, `creatorGuid`, `giftCreatorGuid`, `count`, `duration`, `charges`, `flags`, `enchantments`, `randomPropertyId`, `durability`, `playedTime`, `text`)
VALUES (@ig_12_1, 28789, @receiver, 0, 0, 1, 0, NULL, 0, '', 0, 0, 0, NULL);

SET @next_item_guid := @next_item_guid + 1;
SET @ig_12_2 := @next_item_guid;
INSERT INTO `item_instance` (`guid`, `itemEntry`, `owner_guid`, `creatorGuid`, `giftCreatorGuid`, `count`, `duration`, `charges`, `flags`, `enchantments`, `randomPropertyId`, `durability`, `playedTime`, `text`)
VALUES (@ig_12_2, 29370, @receiver, 0, 0, 1, 0, NULL, 0, '', 0, 0, 0, NULL);

SET @next_item_guid := @next_item_guid + 1;
SET @ig_12_3 := @next_item_guid;
INSERT INTO `item_instance` (`guid`, `itemEntry`, `owner_guid`, `creatorGuid`, `giftCreatorGuid`, `count`, `duration`, `charges`, `flags`, `enchantments`, `randomPropertyId`, `durability`, `playedTime`, `text`)
VALUES (@ig_12_3, 28802, @receiver, 0, 0, 1, 0, NULL, 0, '', 0, 0, 0, NULL);

SET @next_item_guid := @next_item_guid + 1;
SET @ig_12_4 := @next_item_guid;
INSERT INTO `item_instance` (`guid`, `itemEntry`, `owner_guid`, `creatorGuid`, `giftCreatorGuid`, `count`, `duration`, `charges`, `flags`, `enchantments`, `randomPropertyId`, `durability`, `playedTime`, `text`)
VALUES (@ig_12_4, 28825, @receiver, 0, 0, 1, 0, NULL, 0, '', 0, 0, 0, NULL);

SET @next_item_guid := @next_item_guid + 1;
SET @ig_12_5 := @next_item_guid;
INSERT INTO `item_instance` (`guid`, `itemEntry`, `owner_guid`, `creatorGuid`, `giftCreatorGuid`, `count`, `duration`, `charges`, `flags`, `enchantments`, `randomPropertyId`, `durability`, `playedTime`, `text`)
VALUES (@ig_12_5, 29388, @receiver, 0, 0, 1, 0, NULL, 0, '', 0, 0, 0, NULL);

SET @next_mail_id := @next_mail_id + 1;
SET @mid := @next_mail_id;
INSERT INTO `mail` (`id`, `messageType`, `stationery`, `mailTemplateId`, `sender`, `receiver`, `subject`, `body`, `has_items`, `expire_time`, `deliver_time`, `money`, `cod`, `checked`)
VALUES (@mid, 0, 41, 0, 0, @receiver, 'TBC P1 BiS paladin-protection (part 2)', 'Granted by Export-BisSql.ps1 - claim from mailbox.', 1, UNIX_TIMESTAMP() + 86400 * 30, UNIX_TIMESTAMP(), 0, 0, 0);

INSERT INTO `mail_items` (`mail_id`, `item_guid`, `receiver`) VALUES (@mid, @ig_12_1, @receiver),
(@mid, @ig_12_2, @receiver),
(@mid, @ig_12_3, @receiver),
(@mid, @ig_12_4, @receiver),
(@mid, @ig_12_5, @receiver);

COMMIT;

