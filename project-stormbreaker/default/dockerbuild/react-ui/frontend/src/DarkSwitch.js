import React, { useContext } from "react";
import FormControlLabel from "@mui/material/FormControlLabel";
import Switch from "@mui/material/Switch";
import { CustomThemeContext } from "./Layout";

function DarkSwitch() {
  const { themeOverrides, setPaletteMode } = useContext(CustomThemeContext);

  return (
    <FormControlLabel
      control={
        <Switch
          checked={themeOverrides.palette.mode === "dark"}
          onChange={({ target: { checked } }) =>
            setPaletteMode(checked ? "dark" : "light")
          }
          name="checkedB"
          color="primary"
        />
      }
      label="Dark Mode"
    />
  );
}

export default DarkSwitch;
