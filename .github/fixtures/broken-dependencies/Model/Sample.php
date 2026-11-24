<?php

declare(strict_types=1);

namespace SamJUK\BrokenDependencies\Model;

use Magento\Catalog\Api\ProductRepositoryInterface;

class Sample
{
    public function __construct(
        private readonly ProductRepositoryInterface $productRepository
    ) {
    }

    public function name(string $sku): ?string
    {
        return $this->productRepository->get($sku)->getName();
    }
}
