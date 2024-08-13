Listen {{HTTP_PORT}}

<IfModule ssl_module>
	Listen {{HTTPS_PORT}}
</IfModule>

<IfModule mod_gnutls.c>
	Listen {{HTTPS_PORT}}
</IfModule>
