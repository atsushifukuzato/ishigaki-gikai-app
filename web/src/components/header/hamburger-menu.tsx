"use client";

import { Menu } from "lucide-react";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import { routes } from "@/lib/routes";
import { RubyToggle } from "@/lib/rubyful";

export function HamburgerMenu() {
  return (
    <Popover>
      <PopoverTrigger asChild>
        <Button
          variant="ghost"
          size="icon"
          className="h-10 w-10"
          aria-label="メニューを開く"
        >
          <Menu className="h-5 w-5" />
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-56" align="end">
        <div className="flex flex-col gap-3">
          <Link
            href={routes.members()}
            className="text-sm font-bold text-slate-700 transition-colors hover:text-black"
          >
            議員名簿
          </Link>
          <RubyToggle />
        </div>
      </PopoverContent>
    </Popover>
  );
}
