<?php
/**
 * Example PHPUnit test
 *
 * @package EPDC
 */

use PHPUnit\Framework\TestCase;
use EPDC\BaseService;

/**
 * Test case for BaseService
 */
class BaseServiceTest extends TestCase {
	/**
	 * Test BaseService initialization
	 */
	public function test_base_service_init(): void {
		$service = new BaseService();
		$this->assertInstanceOf( BaseService::class, $service );
	}
}