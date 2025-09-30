start-sleep 5
cmd.exe /c "cmdkey /add:pioneerserver /user:xyz /pass:xyz"

net use p: \\pioneerserver\installs 
while (test-path P:\){
	net use P: /delete

}
