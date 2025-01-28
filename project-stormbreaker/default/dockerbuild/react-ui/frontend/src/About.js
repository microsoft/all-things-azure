import { Typography } from "@mui/material";
import Link from "@mui/material/Link";
import Paper from "@mui/material/Paper";
import * as React from "react";

function preventDefault(event) {
  event.preventDefault();
}

export default function About() {
  return (
    <React.Fragment>
      <Typography variant="h5" gutterBottom>
        Project-Stormbreaker
      </Typography>
      <Typography variant="subtitle1" gutterBottom>
        Running simulation models on Azure Kubernetes Services.
      </Typography>
      <Paper elevation={3} style={{ padding: '1rem', marginTop: '2rem' }}>
        <Typography variant="h6" gutterBottom>
          Architecture
        </Typography>
        <img src="https://github.com/appdevgbb/Project-Stormbreaker/raw/main/assets/architecture.png" alt="Project-Stormbreaker Architecture" style={{ maxWidth: '100%' }} />
        <Typography variant="body1" gutterBottom>
          Project-Stormbreaker is a platform for deploying ADCIRC/SWAN on Azure Kubernetes Services using Terraform as Infrastructure as Code. Our target audience includes anyone looking for this deployment.
          <br /><br />
          ADCIRC is a powerful computing program used to predict water levels and currents in coastal areas. HEC-RAS simulates water flow in rivers, channels, and other bodies of water. ADCIRC can be run in parallel with SWAN to simulate storm surge and wave propagation during a hurricane. This integration provides critical data for emergency planning and response.
          <br /><br />
          To learn more about our project, please visit our website: <Link href="https://github.com/appdevgbb/Project-Stormbreaker/tree/main">https://github.com/appdevgbb/Project-Stormbreaker/tree/main</Link>
        </Typography>
      </Paper>

    </React.Fragment>
  );
}
