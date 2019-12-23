<?php
/**
 * SAML 2.0 remote SP metadata for SimpleSAMLphp.
 *
 * See: https://simplesamlphp.org/docs/stable/simplesamlphp-reference-sp-remote
 */

if (!getenv('SIMPLESAMLPHP_SP_ENTITY_ID')) {
    throw new UnexpectedValueException('SIMPLESAMLPHP_SP_ENTITY_ID is not defined as an environment variable.');
}
if (!getenv('SIMPLESAMLPHP_SP_ASSERTION_CONSUMER_SERVICE')) {
    throw new UnexpectedValueException('SIMPLESAMLPHP_SP_ASSERTION_CONSUMER_SERVICE is not defined as an environment variable.');
}

$metadata[getenv('SIMPLESAMLPHP_SP_ENTITY_ID')] = array(
    'AssertionConsumerService' => getenv('SIMPLESAMLPHP_SP_ASSERTION_CONSUMER_SERVICE'),
    'SingleLogoutService' => getenv('SIMPLESAMLPHP_SP_SINGLE_LOGOUT_SERVICE'),
);
