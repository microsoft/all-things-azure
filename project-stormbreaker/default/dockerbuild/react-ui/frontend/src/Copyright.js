import * as React from "react";
import Typography from "@mui/material/Typography";
import Link from "@mui/material/Link";

export default function Copyright(props) {
  return (
    <Typography variant="body2" color="text.secondary" align="center" {...props}>
      <Link color="inherit" href="https://github.com/appdevgbb/Project-Stormbreaker/">
        {'Stormbreaker'}
      </Link>{' '}
      {'is brought you by the '}
      <Link color="inherit" href="https://azureglobalblackbelts.com/">
        Azure App Innovation Global Black Belt
      </Link>{' team.'}
    </Typography>
  );
}