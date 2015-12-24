#!/bin/bash
# LGSM fn_install_complete function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="061115"

if [ "${gamename}" == "Dont Starve Together" ]; then
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
