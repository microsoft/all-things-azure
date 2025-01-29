import React, { useState, useEffect, createContext } from "react";
import { Outlet } from "react-router-dom";
import Box from "@mui/material/Box";
import Toolbar from "@mui/material/Toolbar";
import Container from "@mui/material/Container";
import Copyright from "./Copyright";
import { createTheme, ThemeProvider } from "@mui/material/styles";
import CssBaseline from "@mui/material/CssBaseline";

import AppBar from "./AppBar";
import Drawer from "./Drawer";
import { useTheme } from "./Theme";
export const drawerWidth = 240;
export const CustomThemeContext = createContext();

function Layout() {
  const [open, setOpen] = useState(true);
  const themeContext = useTheme();
  const { themeOverrides } = themeContext;
  const [muiTheme, setMuiTheme] = useState(createTheme(themeOverrides));

  useEffect(() => {
    setMuiTheme(createTheme(themeOverrides));
  }, [themeOverrides]);

  const toggleDrawer = () => {
    setOpen(!open);
  };

  return (
    <CustomThemeContext.Provider value={themeContext}>
      <ThemeProvider theme={muiTheme}>
        <Box sx={{ display: "flex" }}>
          <CssBaseline />
          <AppBar toggleDrawer={toggleDrawer} open={open} />
          <Drawer toggleDrawer={toggleDrawer} open={open} />
          <Box
            component="main"
            sx={{
              backgroundColor: (theme) =>
                theme.palette.mode === "light"
                  ? theme.palette.grey[100]
                  : theme.palette.grey[900],
              flexGrow: 1,
              height: "100vh",
              overflow: "auto",
            }}
          >
            <Toolbar />
            <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
              <Outlet />
              <Copyright sx={{ pt: 4 }} />
            </Container>
          </Box>
        </Box>
      </ThemeProvider>
    </CustomThemeContext.Provider>
  );
}

export default Layout;
