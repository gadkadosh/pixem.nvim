test:
	nvim --headless --noplugin -c "PlenaryBustedDirectory tests/ { minimal_init = './tests/minimal_init.vim' }"

.PHONE: test
