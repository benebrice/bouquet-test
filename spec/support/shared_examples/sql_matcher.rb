# Sahred Example Group
# https://relishapp.com/rspec/rspec-core/v/2-0/docs/example-groups/shared-example-group

shared_examples_for 'an sql query' do |sql|
  it 'validates SQL query synthaxe' do
    expect(sql).to be_a(String)
    expect(sql).to include('SELECT', 'FROM')
  end
end

shared_examples_for 'an sql response' do |sql, keys|
  let(:res) { OrderService::Recurrence.execute_sql(sql) }

  it 'validates SQL response' do
    expect(res).to be_a(Array)
    expect(res.count).to be > 0
    expect(res.first).to be_a(Hash)
    res.each do |r|
      keys.each do |key|
        expect(r.key?(key)).to be_truthy
      end
    end
  end
end

shared_examples_for 'a sub query' do |sql, sub_sql|
  it 'contains sub sql query' do
    expect(sql).to include(sub_sql)
  end
end
