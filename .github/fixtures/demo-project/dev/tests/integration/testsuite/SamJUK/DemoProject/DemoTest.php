<?php

namespace SamJUK\DemoProject\Test\Integration;

use Magento\Framework\App\Config\ScopeConfigInterface;
use Magento\Framework\App\Config\Storage\WriterInterface;
use Magento\Framework\Module\ModuleListInterface;
use Magento\TestFramework\Helper\Bootstrap;
use PHPUnit\Framework\TestCase;

class DemoTest extends TestCase
{
    /**
     * Only resolvable via the real Magento ObjectManager, which only exists
     * once dev/tests/integration's bootstrap has installed Magento against
     * the configured database - a bare PHPUnit assertTrue can't prove that.
     */
    public function testCoreModuleIsRegisteredAndActive(): void
    {
        $moduleList = Bootstrap::getObjectManager()->get(ModuleListInterface::class);

        $this->assertTrue(
            $moduleList->has('Magento_Store'),
            'Magento_Store was not picked up - the integration DB bootstrap did not run against a real Magento install.'
        );
    }

    /**
     * Round-trips a value through core_config_data to prove the test DB
     * connection from install-config-mysql.php is real, not just reachable.
     */
    public function testCanWriteAndReadConfigFromDatabase(): void
    {
        $objectManager = Bootstrap::getObjectManager();
        $path = 'samjuk_demo_project/test/value';
        $value = 'demo-' . uniqid();

        $objectManager->get(WriterInterface::class)->save($path, $value);
        $objectManager->get(ScopeConfigInterface::class)->clean();

        $this->assertSame($value, $objectManager->get(ScopeConfigInterface::class)->getValue($path));
    }
}
