<?php

$config = array(
    'admin' => array(
        'core:AdminPassword',
    ),

    'example-userpass' => array(
        'exampleauth:UserPass',
        'user1:password' => array(
            'email' => 'user1@example.com',
        ),
        'user2:password' => array(
            'email' => 'user2@example.com',
        ),
    ),

);
