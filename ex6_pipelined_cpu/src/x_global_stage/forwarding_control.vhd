----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Cedric Donges and Vittorio Serra
--
-- Description: Forwards source register values from ex and mem stage to dec stage.
----------------------------------------------------------------------------------

-- TODO
-- IN: rd_select and rd_value from ex and mem stage
-- IN: rs1_select and rs2_select from dec stage
-- IN: rs1_value and rs2_value from wb stage
-- OUT: rs1_value and rs2_value to dec stage
-- OUT: rs1_select and rs2_select to wb stage

-- THE NEWEST VALUE MUST BE FORWARDED!!!
-- caution if forwarding values which comes from mem read
-- 2 forwards, 1 stall path?