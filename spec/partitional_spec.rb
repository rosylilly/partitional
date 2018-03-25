class Telephone < Partitional::Model
  attr_accessor :country, :number

  validates :country, inclusion: { in: %w[+81 +1] }
  validates :number, format: { with: /\d{2}-\d{4}-\d{4}/ }
end

RSpec.describe Partitional do
  context 'standard partitional' do
    let(:model) do
      Class.new do
        include ActiveModel::Model
        include Partitional

        attr_accessor :country, :number

        partition :tel, class_name: 'Telephone'
      end
    end

    subject(:instance) { model.new }

    it { is_expected.to be_respond_to(:tel) }
    it { is_expected.to be_invalid }

    describe '#tel' do
      it { expect(instance.tel).to be_a(Telephone) }
      it 'should pass values' do
        instance.tel.number = '00-0000-1111'
        expect(instance.number).to eq('00-0000-1111')

        instance.number = '00-2222-3333'
        expect(instance.tel.number).to eq('00-2222-3333')
      end

      it 'should set new tel' do
        new_tel = Telephone.new(country: '+81', number: '00-4444-5555')

        instance.tel = new_tel
        expect(instance.number).to eq('00-4444-5555')
      end

      describe '#as_json' do
        subject { instance.tel.as_json }

        it { is_expected.to have_key(:number) }
        it { is_expected.to have_key(:country) }
        it { is_expected.to_not have_key(:record) }
      end
    end
  end

  context 'prefixed partitional' do
    let(:model) do
      Class.new do
        include ActiveModel::Model
        include Partitional

        attr_accessor :tel_country, :tel_number

        partition :tel, class_name: 'Telephone', prefix: :tel
      end
    end

    subject(:instance) { model.new }

    it { is_expected.to be_respond_to(:tel) }
    it { is_expected.to be_invalid }

    describe '#tel' do
      it { expect(instance.tel).to be_a(Telephone) }
      it 'should pass values' do
        instance.tel.number = '000-0000-1111'
        expect(instance.tel_number).to eq('000-0000-1111')

        instance.tel_number = '000-2222-3333'
        expect(instance.tel.number).to eq('000-2222-3333')
      end
    end
  end

  context 'deep mapping partitional' do
    let(:model) do
      Class.new do
        include ActiveModel::Model
        include Partitional

        attr_accessor :country

        partition :tel, class_name: 'Telephone', mapping: { number: 'telephone.number' }

        def telephone
          @telephone ||= Telephone.new(number: '88-9999-0000')
        end
      end
    end

    subject(:instance) { model.new }

    it { is_expected.to be_respond_to(:tel) }
    it { is_expected.to be_invalid }

    describe '#tel' do
      it { expect(instance.tel).to be_a(Telephone) }

      it 'should pass values' do
        expect(instance.tel.number).to eq('88-9999-0000')

        instance.tel.number = '77-6666-5555'
        expect(instance.telephone.number).to eq('77-6666-5555')
      end
    end
  end
end
