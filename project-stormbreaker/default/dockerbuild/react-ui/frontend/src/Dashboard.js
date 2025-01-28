import * as React from "react";
import Grid from "@mui/material/Grid";
import Card from "@mui/material/Card";

import Jobs from "./Jobs";

function MainContent() {
  return (
    <Grid container spacing={3}>
      {/* Recent Jobs */}
      <Grid item xs={12}>
        <Card sx={{ p: 2, display: "flex", flexDirection: "column" }}>
          <Jobs />
        </Card>
      </Grid>
    </Grid>
  );
}
export default MainContent;
