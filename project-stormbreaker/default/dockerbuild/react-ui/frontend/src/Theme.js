import React, { useState, useEffect, createContext } from "react";
import { blue, blueGrey, grey } from "@mui/material/colors";

const localStorageKey = "mission-mui-theme";
// set this to false if you are making changes and want to clear the current local storage
const useLocalStorage = true;

const getDefaultTheme = () =>
  (useLocalStorage && JSON.parse(localStorage.getItem(localStorageKey))) ||
  freshDefaultTheme("dark");

const freshDefaultTheme = (mode) => ({
  palette: {
    mode: mode,
    primary: blue,
    secondary: blueGrey,
  },
  typography: {
    fontFamily: "Oxanium",
  },
  components: {
    // Name of the component
    MuiCard: {
      styleOverrides: {
        // Name of the slot
        root: {
          backgroundColor: mode == "dark" ? grey[900] : grey[100],
        },
      },
    },
  },
});

export function useTheme() {
  const [themeOverrides, setThemeOverrides] = useState(getDefaultTheme());

  function setPaletteMode(mode) {
    setThemeOverrides({
      ...freshDefaultTheme(mode),
    });
  }

  useEffect(() => {
    localStorage.setItem(localStorageKey, JSON.stringify(themeOverrides));
  }, [themeOverrides]);

  return { themeOverrides, setThemeOverrides, setPaletteMode };
}
