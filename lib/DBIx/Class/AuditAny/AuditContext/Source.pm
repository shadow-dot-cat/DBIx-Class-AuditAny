package DBIx::Class::AuditAny::AuditContext::Source;
use Moose;
extends 'DBIx::Class::AuditAny::AuditContext';

# VERSION
# ABSTRACT: Default 'Source' context object class for DBIx::Class::AuditAny

has 'ResultSource', is => 'ro', required => 1;
has 'source', is => 'ro', lazy => 1, default => sub { (shift)->ResultSource->source_name };
has 'class', is => 'ro', lazy => 1, default => sub { $_[0]->SchemaObj->class($_[0]->source) };
has 'from', is => 'ro', lazy => 1, default => sub { (shift)->ResultSource->source_name };
has 'table', is => 'ro', lazy => 1, default => sub { (shift)->class->table };

sub primary_columns { return (shift)->ResultSource->primary_columns }

sub _build_tiedContexts { [] }
sub _build_local_datapoint_data { 
	my $self = shift;
	return { map { $_->name => $_->get_value($self) } $self->get_context_datapoints('source') };
}

has 'pri_key_column', is => 'ro', isa => 'Maybe[Str]', lazy => 1, default => sub { 
	my $self = shift;
	my @cols = $self->primary_columns;
	return undef unless (scalar(@cols) > 0);
	my $sep = $self->primary_key_separator;
	return join($sep,@cols);
};

has 'pri_key_count', is => 'ro', isa => 'Int', lazy => 1, default => sub { 
	my $self = shift;
	return scalar($self->primary_columns);
};

sub get_pri_key_value {
	my $self = shift;
	my $Row = shift;
	my @num = $self->pri_key_count;
	return undef unless (scalar(@num) > 0);
	return $Row->get_column($self->pri_key_column) if (scalar(@num) == 1);
	my $sep = $self->primary_key_separator;
	return join($sep, map { $Row->get_column($_) } $self->primary_columns );
}

#has 'datapoint_values', is => 'ro', isa => 'HashRef', lazy => 1, default => sub {
#	my $self = shift;
#	return { map { $_->name => $_->get_value($self) } $self->get_context_datapoints('source') };
#};
#
#has 'all_datapoint_values', is => 'ro', isa => 'HashRef', lazy => 1, default => sub {
#	my $self = shift;
#	return {
#		%{ $self->AuditObj->base_datapoint_values },
#		%{ $self->datapoint_values }
#	};
#};

1;