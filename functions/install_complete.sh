#!/bin/bash
# LGSM install_complete.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com

if [ "${gamename}" == "Don't Starve Together" ]; then
  echo ""
  echo "An Authentication Token is required to run this server!"
  echo "Follow the instructions in this link to obtain this key"
  echo "  http://gameservermanagers.com/dst-auth-token"
fi
echo "================================="
echo "Install Complete!"
echo ""
echo "To start server type:"
echo "./${selfname} start"
echo ""
