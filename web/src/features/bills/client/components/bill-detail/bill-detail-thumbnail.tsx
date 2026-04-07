"use client";

import Image from "next/image";
import { useState } from "react";

interface BillDetailThumbnailProps {
  src: string;
  alt: string;
}

export function BillDetailThumbnail({ src, alt }: BillDetailThumbnailProps) {
  const [hasError, setHasError] = useState(false);

  if (hasError) {
    return <div className="w-full h-20 bg-white" />;
  }

  return (
    <div className="relative w-full h-72 md:h-80">
      <Image
        src={src}
        alt={alt}
        fill
        className="object-cover"
        sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
        priority
        onError={() => setHasError(true)}
      />
    </div>
  );
}
