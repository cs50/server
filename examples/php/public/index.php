<pre>
[<?= getenv("PASSENGER_NGINX_CONFIG_TEMPLATE"); ?>]
<?php print_r($_SERVER); ?>
</pre>

<?= phpinfo(); ?>
