import { TopicItem } from "../../client/components/topic-item";
import type { TopicBillOption, TopicWithBillCount } from "../../shared/types";

type TopicListProps = {
  topics: TopicWithBillCount[];
  billOptions: TopicBillOption[];
};

export function TopicList({ topics, billOptions }: TopicListProps) {
  return (
    <div className="space-y-4">
      <h2 className="text-lg font-semibold">
        トピック一覧 ({topics.length}件)
      </h2>

      {topics.length === 0 ? (
        <p className="text-gray-500">トピックがありません</p>
      ) : (
        <div className="space-y-2">
          {topics.map((topic) => (
            <TopicItem key={topic.id} topic={topic} billOptions={billOptions} />
          ))}
        </div>
      )}
    </div>
  );
}
